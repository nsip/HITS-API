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
	};
};

get '/:token/object/:table' => sub {
	my $school_app = getToken(params->{token});
	if (!$school_app) {
		return status_not_found("token not found");
	}

	my $map = {
		school => q{
			SELECT RefId as id, SchoolName as title
			FROM SchoolInfo
			WHERE RefId = ?
			ORDER BY RefId
			LIMIT 100
		},
		student => q{
			SELECT RefId as id, GivenName as first_name, FamilyName as last_name
			FROM StudentPersonal
			WHERE SchoolInfo_RefId = ?
			ORDER BY RefId
			LIMIT 100
		},
		teacher => q{
			SELECT RefId as id, GivenName as first_name, FamilyName as last_name
			FROM StaffPersonal
			WHERE SchoolInfo_RefId = ?
			ORDER BY RefId
			LIMIT 100
		},
	};

	my $sth = database('SIF')->prepare($map->{params->{table}});
	$sth->execute($school_app->{school_id});
	return {
		data => $sth->fetchall_arrayref({}),
	};
};

true;
