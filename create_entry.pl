#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use Data::UUID;

my $app_id = shift || die("Must provide an APP ID to create for");

# DATABASE
my $dbh_hits = DBI->connect(XXX);
my $dbh_sif = DBI->connect(XXX);

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
	$app = $sth->fetchrow_hashreh || die("No valid app for $app_id");
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
	$sth->execute($app->{sis_id};
	$sis = $sth->fetchrow_hashref || die("No valid SIS from $app_id " . $app->{sis_id});
}

# TEST - SIS is valid data entry
if ($sis->{sis_type} ne 'hits_database') {
	die "SIS of type hits_database only supported";
}

# DBH - Connect to the SIS Database
my $dbh_sis = DBI->connect(XXX);
if (!$dbh_sis) {
	die "No valid SIS Databse from DB Name = ";
}

# TEST - SIS database exists and has data (schools)

# GENERATE - Identifiers to be used
my $app_key = uuid();	# App key can be anything unique
my $password = uuid();	# Password - make it a hash of UUID or similar
my $user_token = uuid();	# UUID for User token, also equals zone.

# MAKE - sif.SIF3_APP_TEMPLATE entry - generate Token & Password
my $sif_template;
{
	my $sth = $dbh_sif->prepare(q{
		INSERT INTO SIF3_APP_TEMPLATE
			(SOLUTION_ID, APPLICATION_KEY, PASSWORD, USER_TOKEN, AUTH_METHOD)
		VALUES
			('HITS', ?, ?, ?, 'Basic')
	});
	$sth->execute($app_key, $password, $user_token);
	$sth = $dbh_sif->prepare(q{
		SELECT APP_TEMPLATE_ID FROM SIF3_APP_TEMPLATE WHERE APPLICATION_KEY = ?
	});
	$sth->execute($app_key);
	$sif_template = $sth->fetchrow_hashref;
}

# MAKE - sif.Zone using (Token?)
{
	my $sth = $dbh_sif->prepare(q{
		INSERT INTO Zone
			(zoneId, databaseUrl)
		VALUES
			(?, ?)
	});
	$sth->execute($user_token, $sis->{sis_ref});	 # TODO Check sis_ref is same format
}

# MAKE - sif.Zone_School - map all schools from the SIS
{
	my $sth = $dbh_sif->prepare('SELECT RefId FROM SchoolInfo');
	$sth->execute();
	my $ins = $dbh_sif->prepare(q{
		INSERT IGNORE INTO Zone_School (zone_id, SchoolInfo_RefId) VALUES (?, ?)
	});
	while (my $ref = $sth->fetchrow_hashref) {
		$ins->execute($user_token, $ref->{RefId});
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


exit;


sub uuid {
	my $ug = Data::UUID->new;
	return $ug->create_str();
}
