package HITS::API::View;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use HITS::API::Plugin;

=head1 NAME

HITS::API::View - View avialable data directly for testing

=cut

our $VERSION = '0.1';
prefix '/view';
set serializer => 'JSON';

# List tables
get '/' => sub {
	my $ret = {};
	foreach my $t (database('SIF')->tables) {
		$t =~ s/^.+\.//;
		$t =~ s/'//g;
		$t =~ s/`//g;
		$ret->{$t} = {
			href => uri_for('view/' . $t) . '',
		};
	}
	return {
		table => $ret,
	};
};

# List data
get '/:id' => sub {
	# TODO - Add some href links & allow configurable limits, filters and sorting
	my $sth = database('SIF')->prepare('SELECT * FROM ' . params->{id} . ' LIMIT 250');
	info('SELECT * FROM ' . params->{id} . ' LIMIT 250');
	$sth->execute;
	return {
		data => $sth->fetchall_arrayref({}),
	};
};

true;
