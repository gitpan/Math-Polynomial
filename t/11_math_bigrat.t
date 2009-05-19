# Copyright (c) 2007-2008 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 11_math_bigrat.t'

#########################

use strict;
use Test;
BEGIN {
    if (!eval "require Math::BigRat") {
        print "1..0 # SKIP Math::BigRat not available\n";
        exit 0;
    }
    Math::BigRat->import(try => 'GMP,Pari');
    plan tests => 8;
}
use Math::Polynomial 1.000;
ok(1);  # modules loaded

my $c0 = Math::BigRat->new('-1/2');
my $c1 = Math::BigRat->new('0');
my $c2 = Math::BigRat->new('3/2');
my $p  = Math::Polynomial->new($c0, $c1, $c2);

my $x1 = Math::BigRat->new('1/2');
my $x2 = Math::BigRat->new('2/3');
my $x3 = Math::BigRat->new('1');
my $y1 = Math::BigRat->new('-1/8');
my $y2 = Math::BigRat->new('1/6');
my $y3 = Math::BigRat->new('1');

ok($y1 == $p->evaluate($x1));
ok($y2 == $p->evaluate($x2));
ok($y3 == $p->evaluate($x3));

my $q = $p->interpolate([$x1, $x2, $x3], [$y1, $y2, $y3]);
ok($p == $q);

my $x = $p->monomial(1);
my $y = eval { $x - $p->coeff_one };
ok(ref($y) && $y->isa('Math::Polynomial'));
ok(1 == $y->degree);
ok($p->coeff_zero == $y->evaluate($x3));

#########################

__END__
