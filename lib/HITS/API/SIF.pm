package HITS::API::SIF;
package HITS::API::View;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use HITS::API::Plugin;

our $VERSION = '0.1';
prefix '/sif';
set serializer => 'JSON';

# XXX
# 	Vendor:
# 		Create an App
#			POST /app/
# 		List Apps
#			GET /app/ - include 
# 		Create SIS DB and populate it
#			GET /app/{ABC-123}
#			POST /sif/{ABC-123}
# 		Join them together
# 	Sysadmin:
# 		View all
# 		Create any

get '/' => sub {
	
};

any '/:id' => sub {
	# --------------------
	# check if exists, 
	my $es = database->prepare('SELECT * FROM app_login WHERE app_id = ?');
	$es->execute(params->{id});
	my $exist = $es->fetchrow_hashref();
	if ($exist && $exist->{app_id} && $exist->{app_template_id}) {
		return {
			data => {
				#Vendor => $app->{vendor_id},
				#APP_ID => $app->{id},
				#Database => $sis->{sis_ref},
				#Solution_ID => $sif_template->{SOLUTION_ID},
				#APP_Key => $sif_template->{APPLICATION_KEY},
				#Password => $sif_template->{PASSWORD},
				#User_Token => $sif_template->{USER_TOKEN},
			},
			success => 1,
			created => 0,
			note => 'Already exists',
			database => 'NA',
		};
	}

	# --------------------
	# CREATE
	my $dbmsg;
	my $new = eval {
		# --------------------
		# create new database in sis entry field
		# (note - race condition...)
		my $sth = database->prepare("SELECT id FROM sis WHERE id LIKE 'hits_db_%'");
		$sth->execute;
		my $next = 0;
		while (my $ref = $sth->fetchrow_hashref()) {
			if ($ref->{id} =~ /^hits_db_(\d+)$/) {
				if ($1 > $next) { $next = $1 }
			}
		}
		$next++;

		$sth = database->prepare("INSERT INTO sis (id, sis_type, sis_ref) VALUES (?, ?, ?)");
		$sth->execute("hits_db_$next", "hits_database", "hits_db_$next");
		$sth = database->prepare("UPDATE app SET sis_id = ? WHERE id = ?");
		$sth->execute("hits_db_$next", params->{id});
		
		# --------------------
		# create new Database (from sif-data/bin/timetable.sh
		$ENV{HOME} = "/home/scottp";
		open (my $RUN, config->{hits_create}{command} . " hits_db_$next 2>&1 |");
		while(<$RUN>) {
			$dbmsg .= $_;
		}
		# die "CMD = " . config->{hits_create}{command} . " hits_db_$next 2>&1; EXIT = $?; Message = $runbuf";

		# --------------------
		# create DB Entries (from create_entry.pl)
		create(params->{id});
	};
	if ($@) {
		return {
			error => $@,
			success => 0,
			id => 'XXX',
			created => 0,
			note => 'Error, see error and database',
			database => $dbmsg,
		};
	}
	else {
		return {
			data => $new,
			success => 1,
			id => 'XXX',
			created => 1,	# XXX did we create this time, or already existing
			note => 'Success, created new DB',
			database => $dbmsg,
		};
	}
};

sub create {
	my ($app_id) = @_;

	# DATABASE
	my $dbh_hits = database;
	my $dbh_sif = database('INFRA');

	# PREPARE - Create the SIS & APP first
	#	sis_vendor_edval - Database name (data created)
	#	SIS ID = 'vendor_edvaĺ' (TODO)
	#	APP ID = '???' (TODO)

	# TEST - app_id exists
	my $app;
	{
		my $sth = $dbh_hits->prepare(q{
			SELECT
				*
			FROM
				app
			WHERE
				id = ?
		});
		$sth->execute($app_id);
		$app = $sth->fetchrow_hashref || die("No valid app for $app_id");
	}

	# TEST - app_id has a SIS
	my $sis;
	{
		my $sth = $dbh_hits->prepare(q{
			SELECT
				*
			FROM
				sis
			WHERE
				id = ?
		});
		$sth->execute($app->{sis_id});
		$sis = $sth->fetchrow_hashref || die("No valid SIS from $app_id " . $app->{sis_id});
	}

	# TEST - SIS is valid data entry
	if ($sis->{sis_type} ne 'hits_database') {
		die "SIS of type hits_database only supported";
	}

	# DBH - Connect to the SIS Database
	my $dbh_sis;
	{
		my $dsn = config->{hits_create}{template};
		my $db = $sis->{sis_ref};
		$dsn =~ s/TEMPLATE/$db/;
		$dbh_sis = DBI->connect(
			$dsn,
			config->{hits_create}{username},
			config->{hits_create}{password},
			{RaiseError => 1, AutoCommit => 1}
		);
		if (!$dbh_sis) {
			die "No valid SIS Databse from DB Name = ";
		}
	}

	# TEST - SIS database exists and has data (schools)

	# GENERATE - Identifiers to be used
	my $app_key = uuid();	# App key can be anything unique
	my $password = uuid();	# Password - make it a hash of UUID or similar
	my $user_token = uuid();	# UUID for User token, also equals zone.

	# MAKE - sif.SIF3_APP_TEMPLATE entry - generate Token & Password
	my $sif_template;
	{
		my $sth = $dbh_sif->prepare(q{SELECT max(APP_TEMPLATE_ID) as max FROM SIF3_APP_TEMPLATE});
		$sth->execute();
		my $max = $sth->fetchrow_hashref;
		my $id = $max->{max} + 1;
		# print "GENERATING APP TEMPLATE - $app_key, $password, $user_token = $id\n";
		$sth = $dbh_sif->prepare(q{
			INSERT INTO SIF3_APP_TEMPLATE
				(APP_TEMPLATE_ID, SOLUTION_ID, APPLICATION_KEY, PASSWORD, USER_TOKEN, AUTH_METHOD, ENV_TEMPLATE_ID)
			VALUES
				(?, 'HITS', ?, ?, ?, 'Basic', 'HITS')
		});
		$sth->execute($id, $app_key, $password, $user_token);
		$sth = $dbh_sif->prepare(q{
			SELECT * FROM SIF3_APP_TEMPLATE WHERE APPLICATION_KEY = ?
		});
		$sth->execute($app_key);
		$sif_template = $sth->fetchrow_hashref;
	}

	# MAKE - sif.Zone using (Token?)
	my $zone;
	{
		my $sth = $dbh_sif->prepare(q{
			INSERT INTO Zone
				(zoneId, databaseUrl)
			VALUES
				(?, ?)
		});
		$sth->execute($user_token, $sis->{sis_ref});	 # TODO Check sis_ref is same format
		$sth = $dbh_sif->prepare(q{SELECT * FROM Zone WHERE zoneId = ?});
		$sth->execute($user_token);
		$zone = $sth->fetchrow_hashref();
	}

	# MAKE - sif.Zone_School - map all schools from the SIS
	{
		my $sth = $dbh_sis->prepare('SELECT RefId FROM SchoolInfo');
		$sth->execute();
		my $ins = $dbh_sif->prepare(q{
			INSERT IGNORE INTO Zone_School (zone_id, SchoolInfo_RefId) VALUES (?, ?)
		});
		while (my $ref = $sth->fetchrow_hashref) {
			$ins->execute($zone->{id}, $ref->{RefId});
		}
	}

	# MAKE - hits.app_login entry (copy previous ID)
	{
		my $sth = $dbh_hits->prepare(q{
			INSERT INTO app_login
				(app_id, app_template_id)
			VALUES
				(?, ?)
		});
		$sth->execute($app_id, $sif_template->{APP_TEMPLATE_ID});
	}

	return {
		Vendor => $app->{vendor_id},
		APP_ID => $app->{id},
		Database => $sis->{sis_ref},
		Solution_ID => $sif_template->{SOLUTION_ID},
		APP_Key => $sif_template->{APPLICATION_KEY},
		Password => $sif_template->{PASSWORD},
		User_Token => $sif_template->{USER_TOKEN},
	};
}

# XXX Plugin
sub uuid {
	my $ug = Data::UUID->new;
	return $ug->create_str();
}

=head1 OLD

register createId => sub {
	my $guid = Data::GUID->new;
	return $guid->as_string;
};

register currentUser => sub {

	# XXX
};

# XXX Hack for MySQL
register getLastId => sub {
	my ($self, $args) = plugin_args(@_);

	$args->{database} //= database;
	my $sth = $args->{database}->prepare("select last_insert_id()");
	$sth->execute();
	my ($last_insert_id) = $sth->fetchrow_array();
	return $last_insert_id;

	#my $sth = database->prepare(
	#	q{SELECT LAST_INSERT_ID() as last FROM } . $args->{table}
	#);
	#$sth->execute();
	#my $ref = $sth->fetchrow_hashref();
	#return $ref->{last};
};

register_plugin;

true

=cut

1;

