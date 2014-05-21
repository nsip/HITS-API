#!/usr/bin/perl
use DBI;
use YAML;
use Spreadsheet::WriteExcel;
use Data::Dumper;
use HTML::Entities;

my $config = YAML::LoadFile($ENV{HOME} . "/.nsip_sif_data");

# Connect to database
my $dbh = DBI->connect(
        'dbi:mysqlPP:database=hits;host=sifau.cspvdo7mmaoe.ap-southeast-2.rds.amazonaws.com',
        $config->{mysql_user}, 
        $config->{mysql_password},
        {RaiseError => 1, AutoCommit => 1}
);

# Create a new Excel workbook
my $workbook = Spreadsheet::WriteExcel->new('out.xls');
$worksheet = $workbook->add_worksheet();
open (my $html, "> out.html");
print $html qq{<html><body><table border="1">\n};

# FIELDS
my $sth = $dbh->prepare(q{
	SELECT DISTINCT
		field
	FROM
		vendor_info
});
$sth->execute();
my $fields = {};
my $count = 0;
$worksheet->write(0, 0, 'vendor_id');
while (my $ref = $sth->fetchrow_hashref) {
	$count++;
	$fields->{$ref->{field}} = $count;
	$worksheet->write(0, $count, $ref->{field});
}

# Vendors
$sth = $dbh->prepare(q{
	SELECT 
		*
	FROM
		vendor
});
$sth->execute();
my $vendors = {};
while (my $ref = $sth->fetchrow_hashref) {
	$vendors->{$ref->{id}} = $ref->{name};
}

# Data
$sth = $dbh->prepare(q{
	SELECT
		*
	FROM
		vendor_info
	ORDER BY
		vendor_id
});
$sth->execute();

my $row = 0;
my $vendor_id = undef;
while (my $ref = $sth->fetchrow_hashref) {
	if ($vendor_id ne $ref->{vendor_id}) {
		$row++;
		$vendor_id = $ref->{vendor_id};
		$worksheet->write($row, 0, $vendor_id);
		$worksheet->write($row, 1, $vendors->{$vendor_id});
	}
	$worksheet->write($row, $fields->{$ref->{field}} + 1, $ref->{value});
}

# decode_entities($a);
print $html q{</body></html>};

