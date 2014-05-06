#!/usr/bin/perl
use warnings;
use strict;
use DBI;
use Data::Dumper;

my $dbh_hits = DBI->connect("DBI:mysqlPP:database=hits;host=sifau.cspvdo7mmaoe.ap-southeast-2.rds.amazonaws.com", "sifau", "03_SIS_was_not");
my $dbh_sis = DBI->connect("DBI:mysqlPP:database=X;host=sifau.cspvdo7mmaoe.ap-southeast-2.rds.amazonaws.com", "sifau", "03_SIS_was_not");

# Map schools in other database to local.

# READ Local List
my $sth = $dbh_hits->prepare('SELECT * FROM school');
$sth->execute();
my $local = {};
while (my $ref = $sth->fetchrow_hashref) {
	$local->{$ref->{id}} = $ref->{name};
}

# READ Remote List
$sth = $dbh_sis->prepare('SELECT RefId,SchoolName FROM SchoolInfo');
$sth->execute();
my $remote = {};
while (my $ref = $sth->fetchrow_hashref) {
	$remote->{$ref->{RefId}} = $ref->{SchoolName};
}

# CREATE New Entries
my $create = $dbh_hits->prepare(q{INSERT INTO school (id,name) VALUES (?, ?)});
foreach my $id (keys %$remote) {
	if (!exists($local->{$id})) {
		print "NEW $id\n";
		$create->execute($id, $remote->{$id});
	}
}

# ATTEMPT to Cleanup / Remove old or Unused entries
my $delete = $dbh_hits->prepare(q{DELETE FROM school WHERE id = ?});
foreach my $id (keys %$local) {
	if (!exists($remote->{$id})) {
		print "Remove $id\n";
		$delete->execute($id);
	}
}

$dbh_hits->commit();
