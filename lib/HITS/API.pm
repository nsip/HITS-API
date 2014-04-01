package HITS::API;
use perl5i::2;

use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;

use HITS::API:::

our $VERSION = '0.1';
prefix undef;
set serializer => 'JSON';

get '/' => sub {
	return {
		xxx => {
			title => "xxx",
			description => "List of xxx and access to some data",
			href => "" . uri_for('xxx/'),
		},
	}
};

true;
