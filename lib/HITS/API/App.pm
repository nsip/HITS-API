package HITS::API::App;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use HITS::API::Plugin;

our $VERSION = '0.1';
prefix '/app';
set serializer => 'JSON';

# Get current list of tags
#	V0 - Show all Applications associated with this vendor
#		/app - Vendor - you see just your own apps
#		/app - Principal - You get to see a list of all public apps, and all of	yours
#	V1 - Show all Applications you should see (e.g. Vendor vs Principal)
get '/' => sub {

	my $vendor_id = 'ABC-123';	# XXX

	my $base = uri_for('/app/'). "";
	my $sth = database->prepare(qq{
		SELECT
			*
		FROM
			app
		WHERE
			vendor_id = ?
	});
	$sth->execute($vendor_id);
	return {
		app => $sth->fetchall_arrayref({}),
	};
};

# Create new APP (brand new, not associate an app with a school)
post '/' => sub {

	my $sth = database->prepare(q{
		INSERT INTO
			app
			(id, X, Y, Z)
		VALUES
			(?, ?, ?, ?)
	});

	my $id = createId;
	
	# Need:
	#	id				Automatically generated
	#	name			Short name - useful in URLs etc. Unique to this Vendor
	# 	title			Title of the application
	#	description		Full description
	#	site_url		Site URL
	#	about			Optional URL about this application
	#	tags			Tags, such as category
	#	icon			Optional URL for the Icon
	#	public			Yes / No 


	database->commit();
	
	return {
		success => 1,
		id => $id,
	};
};

# Get Full Details for ONE App
get '/:id' => sub {
};

# Update existing
put '/:id' => sub {
};

# Delete existing
del ':id' => sub {
};

true;

