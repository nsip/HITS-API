package HITS::API::Security;
use Dancer ':syntax';
use Dancer::Plugin;
use Dancer::Plugin::Database;
use Dancer::Plugin::REST;
use Params::Check qw[check allow last_error];
use Data::GUID;
use Data::Dumper;
use HITS::API::Plugin;

=head1 NAME

HITS::API::Security - Authentication methods

=head1 METHODS

=cut

hook 'before' => sub {

	if (request->path_info =~ /direct/) {
		header('Access-Control-Allow-Origin' => '*');
		header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Access-Control-Headers, Access-Control-Allow-Origin");
		header("Access-Control-Allow-Methods","POST, GET, OPTIONS, DELETE, PUT, HEAD");
		return;
	}

	my $user;
	if (config->{hits}{user} =~ /^COOKIE:(.+)$/) {
		my $c = $1;
		$user = cookie $c;
		info ("Getting cookie for $c = $user");
	}
	elsif (config->{hits}{user} eq 'REQUEST') {
		$user = request->user;
	}
	else {
		$user = config->{hits}{user};
	}

	# NOTE: This could be moved to at login rather than each request for speed
	info("LOGIN = " . $user);

	if (! $user) {
                return halt(Dancer::Response->new(
                        status => 401,
                        content => q{Not logged in: Please go to /site/},
                ));
	}

	# Lookup / create Login
	my $sth = database->prepare(q{SELECT * FROM login WHERE drupal_id = ?});
	$sth->execute($user);
	my $login = $sth->fetchrow_hashref;
	if (!$login) {
		$login = {
			id => createId,
			drupal_id => $user,
		};
		$sth = database->prepare(q{INSERT INTO login (id, drupal_id) VALUES (?, ?)});
		$sth->execute($login->{id}, $login->{drupal_id});
		info("CREATE LOGIN: " . $login->{id});
	}

	# Lookup / create vendor
	$sth = database->prepare(q{SELECT * FROM vendor WHERE id = ?});
	$sth->execute($login->{id});
	my $vendor = $sth->fetchrow_hashref;
	if (!$vendor) {
		$vendor = {
			id => $login->{id},
			name => $login->{drupal_id} . " VENDOR",
		};
		$sth = database->prepare(q{INSERT INTO vendor (id, name) VALUES (?, ?)});
		$sth->execute($vendor->{id}, $vendor->{name});
		info("CREATE VENDOR: " . $login->{id});
	}

	database->commit();
	# header('Cache-Control' =>  'no-store, no-cache, must-revalidate')
	header('Access-Control-Allow-Origin' => '*');

	var current => {
		login => $login,
		vendor => $vendor,
	};

	my $pi = request->path_info;
	my $cu = $vendor->{id};
	$pi =~ s/currentVendor/$cu/g;
	if (request->path_info ne $pi) {
		debug("Changing path info - mapping currentVendor - $pi");
		request->path_info($pi);
	}
};

true
