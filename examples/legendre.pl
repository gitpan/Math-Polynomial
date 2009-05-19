#!/usr/bin/perl

# Copyright (c) 2008 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Math::Polynomial usage example: calculating Legendre polynomials.

use strict;
use warnings;
use Math::Polynomial 1.000;
use Math::BigRat try => 'GMP,Pari';

# adjust some printing options
$Math::Polynomial::string_config = {
    'fold_sign' => 1,
    'prefix'    => '',
    'suffix'    => '',
};

# create p[0] = 1 and p[1] = x
# using arbitrary precision rational coefficients
my $p0 = Math::Polynomial->new(Math::BigRat->new('1'));
my $p1 = $p0 << 1;
my @p = ($p0, $p1);

# recursion: (n+1)*p[n+1] = (2n+1)*x*p[n] - n*p[n-1]
foreach my $n (1..7) {
    $p[$n+1] = ($p[$n] * $p1 * ($n+$n+1) - $p[$n-1] * $n) / ($n + 1);
}

# print polynomials
foreach my $n (0..$#p) {
    print "P_$n = $p[$n]\n";
}

# demonstrate orthogonality
foreach my $n (0..$#p) {
    foreach my $m (0..$n) {
        my $int = ($p[$n] * $p[$m])->definite_integral(-1, 1);
        print "A(P_$m * P_$n) = $int\n";
    }
}

__END__
