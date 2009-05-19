# Copyright (c) 2007-2008 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 05_euclid.t'

#########################

use strict;
use Test;
BEGIN {
    if (!eval "require Math::BigRat") {
        print "1..0 # SKIP Math::BigRat not available\n";
        exit 0;
    }
    import Math::BigRat;
    plan tests => 17;
}
use Math::BigInt;
use Math::Polynomial 1.000;
ok(1);  # modules loaded

#########################

my $x = Math::Polynomial->monomial(1, Math::BigInt->new('1'));
my $p = 4 * ($x + 1)**2 * ($x - 2) * ($x - 5);
my $q = 5 * ($x + 4) * ($x + 1) * ($x - 2);

my $dd = 2700 * ($x + 1) * ($x - 2);
ok($dd == $p->gcd($q, 'mmod'));

$x = Math::Polynomial->monomial(1, Math::BigRat->new('1'));
$p = 4 * ($x + 1)**2 * ($x - 2) * ($x - 5);
$q = 5 * ($x + 4) * ($x + 1) * ($x - 2);

$dd = 108 * ($x + 1) * ($x - 2);
ok($dd == $p->gcd($q));

my $dd1 = $x->new(Math::BigRat->new('1'));
my $dd2 = $x->new(Math::BigRat->new('32/5'), Math::BigRat->new('-4/5'));
my $mm1 = -5 * ($x + 4) / 108;
my $mm2 =  4 * ($x + 1) * ($x - 5) / 108;

my ($d, $d1, $d2, $m1, $m2) = $p->xgcd($q);
ok($dd  == $d);
ok($dd1 == $d1);
ok($dd2 == $d2);
ok($mm1 == $m1);
ok($mm2 == $m2);

($d, $d1, $d2, $m1, $m2) = $q->xgcd($p);
ok($dd  == $d);
ok($dd2 == $d1);
ok($dd1 == $d2);
ok($mm2 == $m1);
ok($mm1 == $m2);

$dd = eval { $p->gcd($q, 'nonexistent_method') };
ok(!defined($dd) && $@ && $@ =~ /no such method: nonexistent_method/);

my $bad_mod_called = 0;
sub Math::Polynomial::bad_mod {
    my ($this, $that) = @_;
    if (++$bad_mod_called >= 100) {
        # avoid endless loops: return zero polynomial if called too often
        return $this->new;
    }
    return $this;
}

$dd = eval { $p->gcd($q, 'bad_mod') };
ok(!defined($dd) && $@ && $@ =~ /bad modulus operator/);
ok(1 == $bad_mod_called);

$dd = eval { $p->xgcd($q) };
ok(!defined($dd) && $@ && $@ =~ /array context required/);

__END__
p == 4      (x+1)(x+1)(x-2)(x-5)  == 4 x^4 - 20 x^3 - 12 x^2 + 52 x + 40
q == 5 (x+4)     (x+1)(x-2)       ==          5 x^3 + 15 x^2 - 30 x - 40

  40   52  -12  -20    4  | -40 -30  15   5  |   *   4/5
  40   84   12  -32       |                  | -32/5
-216 -108  108            |                  |

 -40  -30   15    5  | -216 -108  108  |   *    5/108
 -40  -20   20       |                 | 20/108
   0    0            |                 |

     40     52    -12    -20      4  | -40 -30  15   5
    200    420     60   -160         |
  -5400  -2700   2700                |

    -40    -30     15      5  | -5400 -2700  2700
-108000 -54000  54000         |
      0      0                |
