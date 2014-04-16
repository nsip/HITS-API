package HITS::API::Tag;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;

=head1 NAME

HITS::API::Tag - Tagging - arbitrary tags for Vendors

=cut

our $VERSION = '0.1';
prefix '/tag';
set serializer => 'JSON';

# PURPOSE: Basic tags

# Get current list of tags
get '/' => sub {
	my $base = uri_for('/action/'). "";
	my $sth = database->prepare(qq{
		SELECT
			*
		FROM
			action
	});
	$sth->execute();
	return {
		action => $sth->fetchall_arrayref({}),
	};
};

get '/:id' => sub {
};

post '/' => sub {
	
};

true;

