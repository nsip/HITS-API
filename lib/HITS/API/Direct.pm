package HITS::API::Direct;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use HITS::API::Plugin;

=head1 NAME

HITS::API::Direct - A simple direct viewer for School / Applications

=cut

our $VERSION = '0.1';
prefix '/direct';
set serializer => 'JSON';

get '/' => {
	return {
		'href' => 'TODO/:token',
	};
}

# List tables
get '/:token' => sub {
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
