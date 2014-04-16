package HITS::API::Vendor;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use HITS::API::Plugin;

=head1 NAME

HITS::API::Vendor - List and maintain vendors

=cut

#
# TODO:
# 	Application Permissios ?
#

our $VERSION = '0.1';
prefix '/vendor';
set serializer => 'JSON';

get '/' => sub {
	# XXX Possible list of vendors ?

	my $base = uri_for('/vendor/'). "";
	my $sth = database->prepare(qq{
		SELECT
			*
		FROM
			vendor
	});
	$sth->execute();
	return {
		vendor => $sth->fetchall_arrayref({}),
	};
};

#post '/' => sub {
#};

get '/:id' => sub {
	my $vendor_id = 'test1';	# XXX
	my $sth = database->prepare(qq{
		SELECT
			*
		FROM
			vendor
		WHERE
			id = ?
	});
	$sth->execute(params->{id});
	return {
		vendor => $sth->fetchrow_hashref,
	};
};

# Update existing
put '/:id' => sub {
	my $vendor_id = 'test1';	# XXX
	my $data = {};
	foreach my $key (qw/name/) {
		if (params->{$key}) {
			$data->{$key} = params->{$key};
		}
	}
	if (scalar (keys %$data)) {
		my $sth = database->prepare(q{
			UPDATE vendor
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

#del ':id' => sub {
#};

true;

