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

# XXX List tables
get '/' => sub {
};

# XXX View a single table
get '/:id' => sub {
};
