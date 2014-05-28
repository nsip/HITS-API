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

#get '/' => {
#	return {
#		'href' => 'TODO/:token',
#	};
#};

sub getToken {
	my ($token) = @_;
	my $sth = database->prepare('SELECT * FROM school_app WHERE token = ?');
	$sth->execute($token);
	return $sth->fetchrow_hashref;
}

# List tables (TODO - remove security from here, only use token)
# XXX Allow trailing "/"
get '/:token' => sub {
	my $school_app = getToken(params->{token});
	if (!$school_app) {
		return status_not_found("token not found");
	}
	my $base = uri_for('direct/' . params->{token}) . "/object";
	return {
		school => {
			title => 'Schools',
			description => '',
			href => "$base/school",
		},
		student => {
			title => 'Students',
			description => '',
			href => "$base/student",
		},
		teacher => {
			title => 'Teachers',
			description => '',
			href => "$base/teacher",
		},
		class => {
			title => 'Classes',
			description => '',
			href => "$base/class",
		},
	};
};

get '/:token/object/:table' => sub {
	my $school_app = getToken(params->{token});
	if (!$school_app) {
		return status_not_found("token not found");
	}

	my $base = uri_for('direct/' . params->{token}) . "/object/" . params->{table} . '/';

	my $map = {
		school => q{
			SELECT 
				RefId as id, SchoolName as title
			FROM 
				SchoolInfo
			WHERE 
				RefId = ?
			ORDER BY 
				RefId
			LIMIT 1000
		},
		student => q{
			SELECT 
				RefId as id, GivenName as first_name, FamilyName as last_name,
				Sex as sex, YearLevel as yearlevel, BirthDate as dob,
				IndigenousStatus as indigenous_status, Email as email
			FROM 
				StudentPersonal
			WHERE 
				SchoolInfo_RefId = ?
			ORDER BY 
				RefId
			LIMIT 1000
		},
		teacher => q{
			SELECT 
				RefId as id, GivenName as first_name, FamilyName as last_name, Email as email, Salutation as salutation
			FROM 
				StaffPersonal
			WHERE 
				SchoolInfo_RefId = ?
			ORDER BY 
				RefId
			LIMIT 1000
		},
		class => qq{
			SELECT 
				TeachingGroup.RefId as id,
				TeachingGroup.ShortName as name,
				TeachingGroup.LongName as title,
				TeachingGroup.LocalId as localid,
				TeachingGroup.SchoolYear as year,
				TeachingGroup.KLA as kla,
				SchoolInfo.SchoolName as school_title,
				concat('$base', TeachingGroup.RefId) as href
			FROM 
				TeachingGroup, SchoolInfo
			WHERE
				TeachingGroup.SchoolInfo_RefId = ?
				AND TeachingGroup.SchoolInfo_RefId = SchoolInfo.RefId
			ORDER BY 
				id
			LIMIT 1000
		},
	};

	my $sth = database('SIF')->prepare($map->{params->{table}});
	$sth->execute($school_app->{school_id});
	return {
		data => $sth->fetchall_arrayref({}),
	};
};

get '/:token/object/class/:id' => sub {
	my $school_app = getToken(params->{token});
	if (!$school_app) {
		return status_not_found("token not found");
	}

	my $sth = database('SIF')->prepare(q{
		SELECT 
			TeachingGroup.RefId as id,
			TeachingGroup.ShortName as name,
			TeachingGroup.LongName as title,
			TeachingGroup.LocalId as localid,
			TeachingGroup.SchoolYear as year,
			TeachingGroup.KLA as kla,
			SchoolInfo.SchoolName as school_title
		FROM 
			TeachingGroup, SchoolInfo
		WHERE
			TeachingGroup.SchoolInfo_RefId = ?
			AND TeachingGroup.RefId = ?
			AND TeachingGroup.SchoolInfo_RefId = SchoolInfo.RefId
		ORDER BY 
			id
		LIMIT 1000
	});
	$sth->execute($school_app->{school_id}, params->{id});
	my $data = {
		info => $sth->fetchrow_hashref,
		students => [],
		teachers => [],
	};
	return status_not_found("teaching group not found") unless ($data->{info});

	# Students
	$sth = database('SIF')->prepare(q{
		SELECT 
			StudentPersonal.RefId as id, 
			StudentPersonal.GivenName as first_name, StudentPersonal.FamilyName as last_name
		FROM 
			StudentPersonal, TeachingGroup_Student
		WHERE
			TeachingGroup_Student.TeachingGroup_RefId = ?
			AND TeachingGroup_Student.StudentPersonal_RefId = StudentPersonal.RefId
	});
	$sth->execute( $data->{info}{id} );
	while (my $ref = $sth->fetchrow_hashref) {
		push @{$data->{students}}, { %$ref };
	}

	# Teachers
	$sth = database('SIF')->prepare(q{
		SELECT 
			StaffPersonal.RefId as id, 
			StaffPersonal.GivenName as first_name, StaffPersonal.FamilyName as last_name,
			StaffPersonal.Salutation as salutation, StaffPersonal.Email as email
		FROM 
			StaffPersonal, TeachingGroup_Teacher
		WHERE
			TeachingGroup_Teacher.TeachingGroup_RefId = ?
			AND TeachingGroup_Teacher.StaffPersonal_RefId = StaffPersonal.RefId
	});
	$sth->execute( $data->{info}{id} );
	while (my $ref = $sth->fetchrow_hashref) {
		push @{$data->{teachers}}, { %$ref };
	}

	return $data;
};

sub client {
        our $client;
        # NOTE: Currently alwyas expiring... (inefficient)
        $client = undef;
        if (!defined $client) {
                $client = SIF::REST->new({
                        endpoint => 'http://rest3api.sifassociation.org/api',
                        # TODO Make this config, or even allow as input
                        # solutionId => 'auTestSolution',
                });
                $client->setupRest();
        }
        return $client;
}

# XXX get, any post ?
get qr{/([^/]+)/sifproxy/(.*)} => sub {
        my ($token, $rest) = splat;
	return {
		token => $token,
		rest => $rest,
	};
};

true;
