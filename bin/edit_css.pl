#!/usr/bin/perl
use warnings;
use strict;

use CGI;
my $q = CGI->new;
if ($q->param('css')) {
	rename "/var/www/lib/all.css", "/var/www/lib/all.css.$$";
	open (my $OUT, "> /var/www/lib/all.css");
	print $OUT $q->param('css');
	close $OUT;
}

print "Content-type: text/html\n\n";
print q{<html><body><form method="post"><textarea cols="80" rows="25" name="css">};

open (my $ALL, "/var/www/lib/all.css");
while (<$ALL>) {
	print $_;
}
close $ALL;
print q{</textarea><br /><input type="submit"></form></body></html>};

