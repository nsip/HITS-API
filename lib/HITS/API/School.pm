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
	my $base = uri_for('/school/'). "";
	my $sth = database->prepare(qq{
		SELECT
			id, name, concat('$base', id) as href
		FROM
			school
	});
	$sth->execute();
	return {
		school => $sth->fetchall_arrayref({}),
	};
};

# Create a new school
post '/' => sub {
	my $sth = database->prepare(q{
		INSERT INTO school
			(id, name)
		VALUES
			(?, ?)
	});

	my $id = createId;
	$sth->execute(
		$id, params->{name}
	);

	database->commit();
	
	return {
		success => 1,
		id => $id,
	};
};

# Get Full Details for ONE App
get '/:id' => sub {
	my $base = uri_for('/school/'). "";
	my $sth = database->prepare(qq{
		SELECT
			id, name, concat('$base', id, '/app') as app
		FROM
			school
		WHERE
			id = ?
	});
	$sth->execute(params->{id});
	return {
		school => $sth->fetchrow_hashref,
	};
};

# Update existing
put '/:id' => sub {
	my $data = {};
	foreach my $key (qw/name/) {
		if (params->{$key}) {
			$data->{$key} = params->{$key};
		}
	}
	if (scalar (keys %$data)) {
		my $sth = database->prepare(q{
			UPDATE school
			SET } . join(", ", map { "$_ = ?" } sort keys %$data) . q{
			WHERE id = ?
		});
		$sth->execute(
			map { $data->{$_} } sort keys %$data,
			params->{id}
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

# ==============================================================================
# School Apps
# ==============================================================================
get '/:id/app' => sub {
	my $base = uri_for('/school/' . params->{id} . '/app/'). "";
	my $sth = database->prepare(qq{
		SELECT
			app.id, app.name, app.title, app.description,
			app.site_url, app.icon_url,
			app.about, app.tags, app.pub,
			app.vendor_id, vendor.name vendor_name,
			concat('$base', app.id) as href
		FROM
			school_app, app, vendor
		WHERE
			school_app.school_id = ?
			AND app.id = school_app.app_id
			AND vendor.id = app.vendor_id
	});
	$sth->execute(params->{id});
	return {
		app => $sth->fetchall_arrayref({}),
	};
};

post '/:id/app' => sub {
	my $sth = database->prepare(q{
		INSERT INTO school_app 
			(school_id, app_id)
		VALUES 
			(?, ?)
	});
	$sth->execute(
		params->{id}, params->{app_id}
	);
	database->commit();
	return {
		success => 1,
	};
};

get '/:id/app/:appId' => sub {
	my $sth = database->prepare(qq{
		SELECT
			app.id, app.name, app.title, app.description,
			app.site_url, app.icon_url,
			app.about, app.tags, app.pub,
			app.vendor_id, vendor.name vendor_name
		FROM
			school_app, app, vendor
		WHERE
			school_app.school_id = ?
			AND school_app.app_id = ?
			AND app.id = school_app.app_id
			AND vendor.id = app.vendor_id
	});
	$sth->execute(params->{id}, params->{appId});
	my $data = $sth->fetchrow_hashref;
	if (!$data) {
		return status_not_found("school app  doesn't exists");
	}

	# SIF Authentication
	$data->{sif} = {
		url => 'http://hits.dev.nsip.edu.au:8080/SIF3InfraREST/hits/environments/environment',
		solution_id =>  'HITS',
		applicaiton_key => 'HITS',
		password => 'hits@nsip',
		user_token => params->{id},
		instance_id => 'VendorXXX-AppYYY',
		#		xml => qq{<environment xmlns="http://www.sifassociation.org/infrastructure/3.0.1">
		#	<solutionId>HITS</solutionId>
		#	<authenticationMethod>Basic</authenticationMethod>
		#	<instanceId>EDVAL-TT</instanceId>
		#	<userToken>D3E34B359D75101A8C3D00AA001A1651</userToken>
		#	<consumerName>Consumer A</consumerName>
		#	<applicationInfo>
		#		<applicationKey>HITS</applicationKey>
		#		<supportedInfrastructureVersion>3.0.1</supportedInfrastructureVersion>
		#		<dataModelNamespace>http://www.sifassociation.org/au/datamodel/1.3</dataModelNamespace>
		#		<transport>REST</transport>
		#		<applicationProduct>
		#		<vendorName>NSIP</vendorName>
		#		<productName>HITS Test Harness</productName>
		#		<productVersion>0.1alpha</productVersion>
		#		</applicationProduct>
		#	</applicationInfo>
		#</environment>},
	};

	# DIRECT Authentication
	$data->{test} = {
		url => 'XXX',
	};

	return $data;
};

del '/:id/app/:appId' => sub {
	my $sth = database->prepare(q{
		DELETE FROM school_app 
		WHERE school_id = ? AND app_id = ?
	});
	$sth->execute(
		params->{id}, params->{app_id}
	);
	database->commit();
	return {
		success => 1,
	};
};

true;

