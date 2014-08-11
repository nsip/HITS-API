package HITS::API::View;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use HITS::API::Plugin;

=head1 NAME

HITS::API::View - View avialable data directly for testing

=head1 DESCRIPTION

1 - View the list of Student Information Systems

2 - For the selected SIS, show the list of tables

3 - For the table, show a limited set of data (1000 rows)

=cut

our $VERSION = '0.1';
prefix '/view';
set serializer => 'JSON';

# NOTE: Viewer now works on a per SIS basis
get '/' => sub {
	# XXX This should be limited ot the Vendor ID
	my $sth = database->prepare('SELECT * FROM sis');
	return {
		':sisId' => {
			href => 'TODO',
		},
		# TODO href for the SIS
		data => $sth->fetchall_arrayref({}),
	};
};

# List tables
get '/:sis' => sub {
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
get '/:sis/:id' => sub {
	# TODO - Add some href links & allow configurable limits, filters and sorting
	my $sth = database('SIF')->prepare('SELECT * FROM ' . params->{id} . ' LIMIT 250');
	info('SELECT * FROM ' . params->{id} . ' LIMIT 250');
	$sth->execute;
	return {
		data => $sth->fetchall_arrayref({}),
	};
};

true;
