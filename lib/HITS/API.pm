package HITS::API;
use perl5i::2;

use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;

use HITS::API::Security;

use HITS::API::App;
use HITS::API::Tag;
use HITS::API::Vendor;
use HITS::API::View;
use HITS::API::School;

our $VERSION = '0.1';
prefix undef;
set serializer => 'JSON';

get '/' => sub {

	return {
		app => {
			title => "app",
			description => "List of app and access to some data",
			href => "" . uri_for('app/'),
		},
		school => {
			title => "school",
			description => "List of school and access to some data",
			href => "" . uri_for('school/'),
		},
		tag => {
			title => "tag",
			description => "List of tag and access to some data",
			href => "" . uri_for('tag/'),
		},
		vendor => {
			title => "vendor",
			description => "List of vendor and access to some data",
			href => "" . uri_for('vendor/'),
		},
		view => {
			title => "view",
			description => "List of view and access to some data",
			href => "" . uri_for('view/'),
		},
	}
};

true;
