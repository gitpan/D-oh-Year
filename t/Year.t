# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
use strict;

use vars qw($Total_tests);

my $loaded;
my $test_num = 1;
BEGIN { $| = 1; $^W = 1; }
END {print "not ok $test_num\n" unless $loaded;}
print "1..$Total_tests\n";
use D'oh::Year; #'
$loaded = 1;
print "ok $test_num\n";
$test_num++;
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
sub ok {
	my($test, $name) = @_;
	print "not " unless $test;
	print "ok $test_num";
	print " - $name" if defined $name;
	print "\n";
	$test_num++;
}

sub eqarray  {
	my($a1, $a2) = @_;
	return 0 unless @$a1 == @$a2;
	my $ok = 1;
	for (0..$#{$a1}) { 
	    unless($a1->[$_] eq $a2->[$_]) {
		$ok = 0;
		last;
	    }
	}
	return $ok;
}

# Change this to your # of ok() calls + 1
BEGIN { $Total_tests = 119 }

# Make sure the curtain is up.
ok( eqarray([localtime], [CORE::localtime]) );
ok( eqarray([gmtime],    [CORE::gmtime]) );
#ok( time == CORE::time);


# Make sure we're getting objects.
ok( ref +(localtime)[5] );
ok( ref +(gmtime)[5] );
#ok( ref time );


my @bad_code = (
				q|"19$year"|,
				q|"20$year"|,
				q|"200$year"|,
				q|"Foo 19$year"|,
				q|"Foo 20$year"|,
				q|"Foo 200$year"|,
				q|'19'.$year|,
				q|'20'.$year|,
				q|'200'.$year|,
				q|$year -= 100|,
				q|$year = $year - 100|,
#				q|sprintf "19%02d", $year|,
#				q|sprintf "20%02d", $year|,
			   );

my @good_code = (
				 q|"${year}19"|,
				 q|"${year}20"|,
				 q|"19 $year"|,
				 q|"20 $year"|,
				 q|1900+$year|,
				 q|$year+1900|,
				 q|$year -= 999|,
				 q|$year = $year - 20938|,
				);

my $test_code = <<'END_OF_CODE';
foreach my $year ((localtime)[5], (gmtime)[5]) {
	foreach my $c (@bad_code) {
		() = eval $c;
		::ok($@ =~ /year/i and $@ =~ /$Error/i);
	}
		
	foreach my $c (@good_code) {
		() = eval $c;
		::ok($@ eq '');
	}
}
END_OF_CODE

my $Error = '';
eval $test_code;

package D'oh::Year::Test::Warn;

use D'oh::Year qw(:WARN);

$SIG{__WARN__} = sub { die join('', 'WARN:',@_) };
$Error = '^WARN:';
eval $test_code;


package D'oh::Year::Test::y2k;

use y2k;

$Error = '';
eval $test_code;
