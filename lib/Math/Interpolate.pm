
# Copyright (C) 1997 Matz Kindahl. All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

=head1 NAME

Math::Interpolate - Interpolation of data into a polynomial.

=cut

package Math::Interpolate;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw(interpolate);

$VERSION = 0.01;

use strict;
use Math::Polynomial;

# RDC stands for "Representation Dependent Coding". I will extend the
# Polynomial package with some dedicated methods to do these things
# later.

=head1 SYNOPSIS

    use Math::Interpolate qw(interpolate);

    my $polynomial = interpolate(1 => 5, 2 => 12, 3 => 6);

=head1 DESCRIPTION

Given a set of pairs of I<x> and I<y> values, C<interpolate> will
return a polynomial which interpolates those values. The data points
are supplied as a list of alternating I<x> and I<y> values.

The degree of the resulting polynomial will be one less than the
number of pairs, e.g. the polynomial in the synopsis will be of
degree 2.

The interpolation is done using B<Lagrange's formula> and the
implementation runs in I<O(n^2)>, where I<n> is the number of pairs
supplied to C<interpolate>.

=cut

sub interpolate {
    my(@x,@y);
    my($x,$y);

    while (defined ($x = shift) && defined ($y = shift)) {
	unshift(@x,$x);
	unshift(@y,$y);
    }

    # Declare and compute the numerator
    my $numerator = Math::Polynomial->new(1);
    foreach (@x) { $numerator->mul1c($_) }
    
    # Declare and compute the polynomial using Lagrange's formula (see
    # separate paper.
    my $result = Math::Polynomial->new(0);
    foreach (@x) {
	my $temp = $numerator->clone();
	$temp->div1c($_);
	my $constant = shift(@y) / $temp->eval($_);
	$result += $constant * $temp;
    }
    return $result;
}

1;

=head1 CAVEAT

Observe that it is a I<bad idea> to use interpolation for
extrapolation, i.e. if you are interpolating a polynomial for
I<x>-values in the range 0 to 10, then you may get terrible results if
you try to predict I<y>-values outside this range. This is true
especially if the true function is not a polynomial.

=head1 DEPENDENCIES

The package C<Math::Polynomial> is required, this module is
distributed together with the C<Math::Polynomial> package since is is
quite small.

=head1 COPYRIGHT

Copyright (C) 1997 Matz Kindahl. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
