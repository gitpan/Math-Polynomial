#!/usr/bin/perl

# Copyright (c) 2009 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Math::Polynomial example: write polynomials in the form of a Horner scheme

use strict;
use warnings;
use Math::Polynomial 1.000;

foreach my $a (-1, 0, 1, 2) {
    foreach my $b (-1, 0, 1) {
        foreach my $c (0, 1) {
            foreach my $d (0, 1) {
                my $p = Math::Polynomial->new($d, $c, $b, $a);
                print "P = ", horner($p), "\n";
            }
        }
    }
}

sub horner {
    my ($p) = @_;
    my $result = undef;
    my $sign = 0;
    my $zero = $p->coeff_zero;
    my $one  = $p->coeff_one;
    foreach my $c (reverse $p->coefficients) {
        if (defined $result) {
            if ($sign) {
                $result = "($result)";
            }
            $result .= '*x';
            $sign = $c <=> $zero;
            if ($sign < 0) {
                $result .= $c;
            }
            elsif ($sign > 0) {
                $result .= "+$c";
            }
        }
        else {
            $result = "$c";
        }
    }
    $result =~ s/((?:^|\()-?)1\*/$1/;       # optimize: 1*x => x
    return $result;
}

__END__
