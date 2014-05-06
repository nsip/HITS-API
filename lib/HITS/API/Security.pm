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

	# NOTE: This could be moved to at login rather than each request for speed

	debug("LOGIN = " . request->user);

	if (! request->user) {
		die "No logged in user";
	}

	# Lookup / create Login
	my $sth = database->prepare(q{SELECT * FROM login WHERE drupal_id = ?});
	$sth->execute(request->user);
	my $login = $sth->fetchrow_hashref;
	if (!$login) {
		$login = {
			id => createId,
			drupal_id => request->user,
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

	var current => {
		login => $login,
		vendor => $vendor,
	};

};

true
