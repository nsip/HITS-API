package HITS::API::School;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use HITS::API::Plugin;

=head1 NAME

HITS::API::School - Manage a school

=cut

our $VERSION = '0.1';
prefix '/school';
set serializer => 'JSON';

get '/' => sub {
	my $vendor_id = 'test1';	# XXX

	my $base = uri_for('/school/'). "";
	# XXX vendor details ?
	my $sth = database->prepare(qq{
		SELECT
			*
		FROM
			school
		WHERE
			vendor_id = ?
	});
	$sth->execute($vendor_id);
	return {
		school => $sth->fetchall_arrayref({}),
	};
};

# Create a new school
post '/' => sub {
	my $vendor_id = 'test1';	# XXX

	my $sth = database->prepare(q{
		INSERT INTO
			app
			(
				id, vendor_id, name, title, description, 
				site_url, icon_url, 
				tags, about, 
				pub
			)
		VALUES
			(
				?, ?, ?, ?, ?,
				?, ?,
				?, ?,
				?
			)
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

	$sth->execute(
		$id, $vendor_id, params->{name}, params->{title}, params->{description},
		params->{site_url}, params->{icon_url}, 
		params->{tags}, params->{about},
		params->{pub}
	);

	database->commit();
	
	return {
		success => 1,
		id => $id,
	};
};

# Get Full Details for ONE App
get '/:id' => sub {
	my $vendor_id = 'test1';	# XXX
	my $sth = database->prepare(qq{
		SELECT
			*
		FROM
			app
		WHERE
			id = ? AND vendor_id = ?
	});
	$sth->execute(params->{id}, $vendor_id);
	return {
		app => $sth->fetchrow_hashref,
	};
};

# Update existing
put '/:id' => sub {
	my $vendor_id = 'test1';	# XXX
	my $data = {};
	foreach my $key (qw/name title description site_url about tags icon public/) {
		if (params->{$key}) {
			$data->{$key} = params->{$key};
		}
	}
	if (scalar (keys %$data)) {
		my $sth = database->prepare(q{
			UPDATE app
			SET } . join(", ", map { "$_ = ?" } sort keys %$data) . q{
			WHERE id = ? AND vendor_id = ?
		});
		$sth->execute(
			map { $data->{$_} } sort keys %$data,
			params->{id}, $vendor_id
		);
	}
	database->commit();
	return {
		success => 1,
	};
};

# Delete existing (XXX security?)
del ':id' => sub {
	my $vendor_id = 'test1';	# XXX
	my $sth = database->prepare(q{DELETE FROM app WHERE id = ? AND vendor_id = ?});
	$sth->execute(params->{id}, $vendor_id);
	return {
		success => 1,
		id => params->{id},
	};
};

true;

