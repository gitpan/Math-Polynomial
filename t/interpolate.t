#                              -*- Mode: Perl -*- 
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'
 
######################### We start with some black magic to print on failure.
 
# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)
 
use lib './lib';
 
BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::Interpolate qw(interpolate);
$loaded = 1;
print "ok 1\n";
 
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $cnt = 10;
TEST2: while ($cnt-- > 0) {
    my(@C,@M);
    my $degree = 5;		# Degree + 1

    my $error = 1e-10;
    # Generate random polynomial
    push(@C, int(rand 10) + 1) while $degree-- > 0;
    
    my $P = Math::Polynomial->new(@C);
    
# Take measurements of the polynomial
    foreach (1..@C) {
	push(@M, 2*$_, $P->eval(2*$_));
    }
    
    my $Q = interpolate(@M);
    
    foreach (0..@C-1) {
	if (abs($P->coeff($_) - $Q->coeff($_)) > $error) {
	    print "not ";
	    last TEST2;
	}
    }
}
print "ok 2 (interpolate)\n";

# Test that the interpolation method works with zero points.

my $polynomial = Math::Interpolate::interpolate(0 => 0, .5 => .5, 1 => 1);

if ($polynomial->degree() == 1
    && $polynomial->coeff(0) == 0 
    && $polynomial->coeff(1) == 1) 
{
    print "ok 3 (interpolate)\n";
} else {
    print "not ok 3 (interpolate)\n";
}

