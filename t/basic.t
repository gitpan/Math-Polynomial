#                              -*- Mode: Perl -*- 
# Copyright (c) 2007 Martin Becker. All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use strict;
use vars qw($loaded);

BEGIN { $| = 1; print "1..60\n"; }
END {print "not ok 1\n" unless $loaded;}

use Math::Polynomial;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

sub check_coeff {
    my ($number, $poly, @coeff) = @_;
    my $ok =
	$poly->degree == $#coeff &&
	!grep { $poly->coeff($_) != $coeff[$_] } 0..$#coeff;
    print !$ok && 'not ', "ok $number ($poly === (@coeff))\n";
}

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

$P = Math::Polynomial->new(3, 2, -3);
if ("$P" ne '3*$X**2 + 2*$X - 3') {
    print "not ('$P' is not correct)";
} else {
    # Example supplied by Sergey that failed before.
    my $a = new Math::Polynomial(1,1);
    $a->verbose(1);
    
    if ("$a" ne '$X + 1') {
	print "not ('$a' is not correct)";
    }
}
print "ok 6 (stringify)\n";

Math::Polynomial->configure(VARIABLE => 'X', POWER => '^');

print "not (since $P is not correct)" 
    unless "$P" eq '3*X^2 + 2*X - 3';
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

# Added test 10 to check for bug reported independently by  
# Sergey V. Kolychev, John Hurst, and Jeffrey S. Haemer
# (Minolta-QMS).

TEST10: {
    $P = Math::Polynomial->new(1,-1);
    goto BAD10 unless "$P" eq 'X - 1';
    $P = Math::Polynomial->new(1,1);
    goto BAD10 unless "$P" eq 'X + 1';
    
    goto GOOD10;

  BAD10:
    print "not ok 10\n";
    goto TEST11;
  GOOD10:
    print "ok 10\n";
}

TEST11:

my $p1 = Math::Polynomial->new(1, -2, 1);
check_coeff 11, $p1, 1, -2, 1;

my $p2 = Math::Polynomial->new(2, 0);
check_coeff 12, $p2, 0, 2;

my $p3;

$p3 = $p1 + $p2;
check_coeff 13, $p3, 1, 0, 1;

$p3 = $p2 + $p1;
check_coeff 14, $p3, 1, 0, 1;

$p3 = $p1 + -1;
check_coeff 15, $p3, 0, -2, 1;

$p3 = -1 + $p1;
check_coeff 16, $p3, 0, -2, 1;

$p3 = $p1 - $p2;
check_coeff 17, $p3, 1, -4, 1;

$p3 = $p2 - $p1;
check_coeff 18, $p3, -1, 4, -1;

$p3 = $p1 - 1;
check_coeff 19, $p3, 0, -2, 1;

$p3 = 1 - $p1;
check_coeff 20, $p3, 0, 2, -1;

$p3 = $p1 - $p1;
check_coeff 21, $p3;

$p3->tidy;
check_coeff 22, $p3;

$p3 = $p1 - $p1->clone;
check_coeff 23, $p3;

$p3 = -$p1;
check_coeff 24, $p3, -1, 2, -1;

my $q1 = $p1 * $p2;
check_coeff 25, $q1, 0, 2, -4, 2;

my $q2 = 1 - $p1 * $p2;
check_coeff 26, $q2, 1, -2, 4, -2;

$p3 = 0.5 * $q1;
check_coeff 27, $p3, 0, 1, -2, 1;

$p3 = $q1 * 0.5;
check_coeff 28, $p3, 0, 1, -2, 1;

$p3 = $q2 / $p1;
check_coeff 29, $p3, 0, -2;

$p3 = $q2 / $q1;
check_coeff 30, $p3, -1;

$p3 = $q2 / -2;
check_coeff 31, $p3, -0.5, 1, -2, 1;

$p3 = -2 / $q2;
check_coeff 32, $p3;

my $q3 = $q1 + Math::Polynomial->new(-2, 0, 0, 0);
print $q3->size != 4 && 'not ', "ok 33 (untidy size)\n";
print $q3->degree != 2 && 'not ', "ok 34 (untidy degree)\n";
check_coeff 35, $q3, 0, 2, -4;

$p3 = $q2 / $q3;
check_coeff 36, $p3, -0.75, 0.5;

my $z0 = Math::Polynomial->new();
check_coeff 37, $z0;

my $z1 = Math::Polynomial->new(0);
check_coeff 38, $z1;

my $msg;

$p3 = eval { $q2 / $z0 };
$msg = $@;
print !$msg && 'not ', "ok 39 (zero division)\n";
print $msg !~ /division by zero/ && 'not ', "ok 40 (zero division)\n";

$p3 = eval { $q2 / $z1 };
$msg = $@;
print !$msg && 'not ', "ok 41 (zero division)\n";
print $msg !~ /division by zero/ && 'not ', "ok 42 (zero division)\n";

$p3 = $z0 / $q3;
check_coeff 43, $p3;

$p3 = $z1 / $q3;
check_coeff 44, $p3;

$p3 = $q2 % $p1;
check_coeff 45, $p3, 1;

$p3 = $q2 % $q1;
check_coeff 46, $p3, 1;

$p3 = $q2 % -2;
check_coeff 47, $p3;

$p3 = -2 % $q2;
check_coeff 48, $p3, -2;

$p3 = $q2 % $q3;
check_coeff 49, $p3, 1, -0.5;

$p3 = eval { $q2 % $z0 };
$msg = $@;
print !$msg && 'not ', "ok 50 (zero division)\n";
print $msg !~ /division by zero/ && 'not ', "ok 51 (zero division)\n";

$p3 = eval { $q2 % $z1 };
$msg = $@;
print !$msg && 'not ', "ok 52 (zero division)\n";
print $msg !~ /division by zero/ && 'not ', "ok 53 (zero division)\n";

$p3 = $z0 % $q3;
check_coeff 54, $p3;

$p3 = $z1 % $q3;
check_coeff 55, $p3;

my ($b, $c);

$c = eval { $q3->coeff(-1) };
$msg = $@;
print !$msg && 'not ', "ok 56 (coeff index)\n";
print $msg !~ /exponent/ && 'not ', "ok 57 (coeff index)\n";

$c = eval { $q3->coeff(10) };
$msg = $@;
print !$msg && 'not ', "ok 58 (coeff index)\n";
print $msg !~ /exponent/ && 'not ', "ok 59 (coeff index)\n";

$c = eval { $q3->coeff(3) };
$msg = $@;
$b = !$@ && defined($c) && 0 == $c;
print !$b && 'not ', "ok 60 (coeff index)\n";

__END__
p1 = x^2 -2x +1
p2 = 2x
q1 = 2x^3 -4x^2 +2x
q2 = -2x^3 +4x^2 -2x +1
q3 = -4x^2 +2x

-2x^3 +4x^2 -2x +1 = (x^2 -2x +1) * (-2x) + (1)
-2x^3 +4x^2 -2x +1 = (2x^3 -4x^2 +2x) * (-1) + (1)
-2x^3 +4x^2 -2x +1 = (-2) * (x^3 -2x^2 +x -0.5) + (0)
-2x^3 +4x^2 -2x +1 = (-4x^2 +2x) * (0.5x -0.75) + (-0.5x +1)
