#                              -*- Mode: Perl -*- 
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'
 
######################### We start with some black magic to print on failure.
 
# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
 
BEGIN { $| = 1; print "1..9\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Polynomial;
use Math::Interpolate qw(interpolate);
$loaded = 1;
print "ok 1\n";
 
######################### End of black magic.
 
# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
 
# This is the polynomial 3x^2 + 2x - 3
my $P = Math::Polynomial->new(3, 2, -3);
print "ok 2 (creating)\n";	# Ain't much that can go wrong

print "not " unless $P->degree() == 2;
print "ok 3 (degree)\n";

print "not " unless "$P" eq "(3 2 -3)";
print "ok 4 (stringify)\n";

$P = Math::Polynomial->new(0,0,0,0,3,2,-3);
$P->tidy();
if ("$P" ne "(3 2 -3)") {
    print "not ";
} else {
    $P->tidy();
    if ("$P" ne "(3 2 -3)") {
	print "not ";
    }
}
print "ok 5 (tidy)\n";

Math::Polynomial->verbose(1);

print "not (since $P is not correct)" 
    unless "$P" eq '3*$X**2 + 2*$X + -3';
print "ok 6 (stringify)\n";

Math::Polynomial->configure(VARIABLE => 'X', POWER => '^');

print "not (since $P is not correct)" unless "$P" eq '3*X^2 + 2*X + -3';
print "ok 7 (stringify)\n";

foreach (1..20) {
    if ($P->eval($_) != 3 * $_ ** 2 + 2 * $_ - 3) {
	print "not ";
	last;
    }
}
print "ok 8 (eval)\n";

my $cnt = 10;
TEST9: while ($cnt-- > 0) {
    my(@A,@B);
    my($i);

    $i = int(rand 10) + 1;	# Degree + 1
    push(@A, int(rand 11) + 1) while $i-- > 0;

    $i = int(rand 10) + 1;	# Degree + 1
    push(@B, int(rand 11) - 5) while $i-- > 0;
    
    my $P = Math::Polynomial->new(@A);
    my $Q = Math::Polynomial->new(@B);
    my $R = $P + $Q;

    for (my $i = 0 ; $i < (@A < @B ? @A : @B) ; $i++) {
	if ($P->coeff($i) + $Q->coeff($i) != $R->coeff($i)) {
	    print
		"not (since ", $P->coeff($i),
		" + ", $Q->coeff($i), " != ", $R->coeff($i), " at ", $i, ")";
	    last TEST8;
	}
    }
}
print "ok 9 (plus)\n";

	    
