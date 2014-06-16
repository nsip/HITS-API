package HITS::SIFTest;
use perl5i::2;
use File::Path;

=head1 NAME

HITS::SIFTest - A basic low level raw SIF API

=cut

my $root = "/tmp/siftest";

sub stats {
	my ($loc) = @_;
	#_prepare($loc, $obj);
	
}

sub _prepare {
	my ($loc, $obj) = @_;
	mkpath "$root/$loc";
	mkpath "$root/$loc/_log";
	if ($obj) {
		mkpath "$root/$loc/$obj/ARCHIVE";
	}
}

sub _log {
	my ($loc, $log, $data) = @_;
	open (my $OUT, ">> $root/$loc/_log/$log.log");
	print $OUT "----\n" . localtime() . "\n" . $data . "\n";
	close $OUT;
}

sub _obj {
	my ($url) = @_;
	$url =~ s|^/||g;
	if ($url =~ m|^([^/]+)s|) {	# Note trailing s
		return $1;
	}
	die "Invalid URL (must be ObjectType/Anything) ($url)";
}

sub _id {
	my ($data) = @_;
	# XXX how to get the id?
	if ($data =~ /RefId="([^"]+)"/) {
		return $1;
	}
	return;
}

sub post {
	my ($loc, $url, $data) = @_;

	my $obj= _obj($url);
	my $id = _id($data);
	_prepare($loc, $obj);

	if (!$id) {
		die "No valid RefId provided for object";
	}
	
	open (my $OUT, "> $root/$loc/$obj/$id.xml");
	print $OUT $data;
	close $OUT;

	open ($OUT, "> $root/$loc/$obj/ARCHIVE/" . time . "_$id.xml");
	print $OUT $data;
	close $OUT;

	_log($loc, 'default', "POST " . $obj . "s/" . $id);

	return $obj . "s/" . $id;
}

sub get {
	my ($loc, $url) = @_;
	
	_prepare($loc);
	my $obj = _obj($url);
	my $id;
	if ($url =~ m|($obj)s/([^/]+)|) {
		$id = $2;
	}

	# Return 1
	if ($id) {
		_log($loc, 'default', "GET " . $obj . "s/" . $id);
		open (IN, "$root/$loc/$obj/$id.xml");
		my $ret = "";
		while (<IN>) {
			$ret .= $_;
		}
		close IN;
		return $ret;
	}

	# Return many
	else {
		_log($loc, 'default', "GET " . $obj . "s");
		my $ret = "<" . $obj . "s>\n";
		opendir(my $DIR, "$root/$loc/$obj");
		while(readdir $DIR) {
			next unless (/\.xml$/);
			s/\.xml$//;
			$id = $_;
			open (IN, "$root/$loc/$obj/$id.xml");
			while (<IN>) {
				$ret .= $_;
			}
			$ret .= "\n";
			close IN;
		}
		$ret .= "</" . $obj . "s>\n";
		return $ret;
	}

}

# Process an existing entry
sub process {
	my ($loc, $url) = @_;

	_prepare($loc);
	my $obj = _obj($url);
	my $id;
	if ($url =~ m|($obj)s/([^/]+)|) {
		$id = $2;
	}

	# XXX 
	# 	- Process a XML file
	# 	- Standard XML processing and rule checking
	# 	- Consider validating against SIF
	# 	- Output userful other data?
	#	- Check object type matches file name and directory
	# 	- Check SIF ref id correct

	eval {
		eval q{
			use lib '../sif-au-perl/lib';
			use SIF::AU;
		};
		die $@ if ($@);
		say "URL = $url";
        my $class = "SIF::AU::$obj";
		my $sa = $class->from_xml(get($loc, $url));

		say "RefId = " . $sa->RefId;
		say "XML from Class = " . $sa->to_xml_string;
		say "XML original = " . get($loc, $url);

		say "Validation...";
		$sa->xml_validate();   
		say "Validation = Success";

		die "Ref ID does not match" if ($sa->RefId ne $id);
	};
	if ($@) {
			die "ERROR $@.";
	}

}

# ADVANCED
# 	- Specific SIF relationships - e.g. TeachingGroups members
#	- POST with no RefId
#			<DanOne>XXX</DanOne> s/^<([A-Z]+)>/<$1 RefId="Generated">/
#	- Generating LIST of items - only passed processing correctly

# ISSUES
# 	- Create multiple at once?
# 	- Return correct Environments string
# 	- Return correct for POST
#	- Delete
#	- Fragment update
#	- Timetablers - by end of June
#
# DASHBOARD
# 	- See list of objects & counts, view objects
# 	- See log and validation data (both in the log and individually)
#
# INTEGRATE
# 	- Can we integrate automatically with SIF
# 	- ie. Just POST what we get onto SIF
#
# DONE
# 	- Log every action - get, post
# 	- Stats about entry - e.g. Post NEW vs POST overwrite
#	- Date Time
#	- Keep all uploads (historic)

1;

