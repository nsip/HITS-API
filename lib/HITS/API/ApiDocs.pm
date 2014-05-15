package HITS::API::ApiDocs;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use HITS::API::Plugin;

=head1 NAME

HITS::API::App - Applications list, and update

=cut

our $VERSION = '0.1';
prefix '/api-docs';
set serializer => 'JSON';

get '/' => sub {
	return {
	  "apiVersion" => "0.0.1",
	  "swaggerVersion" => "1.2",
	  "apis" => [
	    {
	      "path" => "/app",
	      "description" => "Applications",
	    },
	    {
	      "path" => "/view",
	      "description" => "View - direct access to SIS for testing",
	    },
	    {
	      "path" => "/school",
	      "description" => "Schools - List, Adding applications, Tokens",
	    },
	    {
	      "path" => "/vendor",
	      "description" => "Vendors - Details",
	    },
	    {
	      "path" => "/tag",
	      "description" => "Tagging",
	    },
	    {
	      "path" => "/direct",
	      "description" => "Direct - JSON based School/Student/Teacher access",
	    },
	  ],
	  "info" => {
	    "title" => "HITS API",
	    "description" => "Description TODO",
	    "termsOfServiceUrl" => "/site/TODO",
	    "contact" => "info\@nsip.edu.au",
	    "license" => "License TODO",
	    "licenseUrl" => "/site/TODO",
	  }
	};
};

sub makeOperation {
	my ($method, $path, $summary, $params) = @_;
	if (! $params) {
		$params = [];
		foreach my $key ($path =~ /{([^}]+)}/g) {
			push @$params, {
				"name" => $key,
				"description" => "ID for $key",
				"required" => true,
				"type" => "string",
				"paramType" => "path",
			};
		}
	}
	return {
		method => $method,
		summary=> $summary,
		notes => 'TODO Notes',
		type => 'XXX',
		nickname => $method . '_' . $path,
		authorizations => {},
		parameters => $params // {},
		responseMessages => [
			{
				code => 403,
				message => 'Not logged in',
			},
		]
	};
}

sub makeOperationPOST {
	my ($path, $summary, $example) = @_;
	my $params = [];
	foreach my $key ($path =~ /{([^}]+)}/g) {
		push @$params, {
			"name" => $key,
			"description" => "ID for $key",
			"required" => true,
			"type" => "string",
			"paramType" => "path",
		};
	}
	return {
		method => 'POST',
		summary=> $summary,
		notes => 'TODO Notes',
		type => 'XXX',
		nickname => 'POST_' . $path,
		authorizations => {},
		parameters => [
			@$params,
			{
				"name" => "body",
				"description" => "Create object",
				"required" => true,
				"type" => $path,
				defaultValue => ref($example) 
					? to_json( $example, { ascii => 1, pretty => 1 } ) 
					: $example,
				"paramType" => "body"
			}
		],
		responseMessages => [
			{
				code => 403,
				message => 'Not logged in',
			},
		]
	};
}

get '/:id' => sub {
	my $api = params->{id};

	my $apis = {
		app => [
			{
				path => '/app',
				operations => [
					makeOperation('GET', 'app', 'List applications'),
					makeOperationPOST('app', 'Create applications', {
						name => "",
						title => "",
						description => "",
						site_url => "",
						icon_url => "",
						tags => "",
						about => "",
						pub => "",
						perm_template => ""
					}),
				],
			},
			{
				path => '/app/{appId}',
				operations => [
					makeOperation('GET','app/{appId}', 'Get applications'),
					makeOperation('DELETE','app/{appId}', 'Delete applications'),
				],
			},
		],
		vendor => [
			{
				path => '/vendor',
				operations => [
					makeOperation('GET', 'vendor', 'List vendors'),
				],
			},
			{
				path => '/vendor/{vendorId}',
				operations => [
					makeOperation('GET', 'vendor/{vendorId}', 'Get vendor'),
				],
			},
			{
				path => '/vendor/{vendorId}/info',
				operations => [
					makeOperation('GET', 'vendor/{vendorId}/info', 'Vendors meta information'),
					makeOperationPOST('vendor/{vendorId}/info', 'Create vendor meta information', {
						exampleOne => "anything",
						exampleTwo => "you need to store",
					}),
				],
			},
			{
				path => '/vendor/{vendorId}/app',
				operations => [
					makeOperation('GET', 'vendor/{vendorId}/app', 'Get vendor configured by school apps'),
				],
			},
		],
		view => [
			{
				path => '/view',
				operations => [
					makeOperation('GET', 'view', 'List SIS Tables'),
				],
			},
			{
				path => '/view/{tableId}',
				operations => [
					makeOperation('GET', 'view/{tableId}', 'Get table data from SIS'),
				],
			}
		],
		school => [
			{
				path => '/school',
				operations => [
					makeOperation('GET', 'school', 'List Schools'),
				],
			},
			{
				path => '/school/{schoolId}',
				operations => [
					makeOperation('GET', 'school/{schoolId}', 'Get School'),
				],
			},
			{
				path => '/school/{schoolId}/app',
				operations => [
					makeOperation('GET', 'school/{schoolId}/app', 'Get Schools APP List'),
					makeOperationPOST('school/{schoolId}/app', 'Create Schools APP List', {
						app_id => '',
					}),
				],
			},
			{
				path => '/school/{schoolId}/app/{appId}',
				operations => [
					makeOperation('GET', 'school/{schoolId}/app/{appId}', 'Schools APP association including Tokens and Auth data'),
					makeOperation('DELETE', 'school/{schoolId}/app/{appId}', 'DELETE Schools APP association'),
				],
			}
		],
		direct => [
			{
				path => '/direct/{token}',
				operations => [
					makeOperation('GET', 'direct/{token}', 'List available objects'),
				],
			},
			{
				path => '/direct/{token}/object/school',
				operations => [
					makeOperation('GET', 'direct/{token}/object/school', 'List Schools'),
				],
			},
			{
				path => '/direct/{token}/object/student',
				operations => [
					makeOperation('GET', 'direct/{token}/object/student', 'List Students'),
				],
			},
			{
				path => '/direct/{token}/object/teacher',
				operations => [
					makeOperation('GET', 'direct/{token}/object/teacher', 'List Teachers'),
				],
			},
		],
	};

	return {
	  "apiVersion" => "0.0.1",
	  "swaggerVersion" => "1.2",
	  "basePath" => "http://hits.dev.nsip.edu.au/api",
	  "resourcePath" => "/$api",
	  "produces" => [
	    "application/json"
	  ],
	  "authorizations" => {},
	  "apis" => $apis->{$api},
	  "models" => {},
	};
};

true;

