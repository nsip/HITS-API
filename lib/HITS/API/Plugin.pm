package HITS::API::Plugin;
use Dancer ':syntax';
use Dancer::Plugin;
use Dancer::Plugin::Database;
use Dancer::Plugin::REST;
use Params::Check qw[check allow last_error];
use Data::GUID;
use Data::Dumper;

=head1 NAME

TODO

=head1 METHODS

=cut

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
