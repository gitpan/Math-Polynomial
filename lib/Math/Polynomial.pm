# Copyright (c) 2007 Martin Becker. All rights reserved.
#
# This module is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Math::Polynomial;

use 5.005;
use strict;
use base qw(Exporter);
use vars qw($VERSION @EXPORT_OK);
use Carp;

use overload
    '+' => \&plus,
    '-' => \&minus,
    'neg' => \&neg,
    '*' => \&times,
    '/' => sub { (&quotrem)[0] },
    '%' => sub { (&quotrem)[1] },
    '""' => \&to_string;

$VERSION = '0.04';

# plain subroutines may be exported.
@EXPORT_OK = qw(quotrem interpolate);

=head1 NAME

Math::Polynomial - Perl class for working with polynomials.

=head1 VERSION

This document describes Math::Polynomial version 0.04.

=head1 SYNOPSIS

    use Math::Polynomial;

     # The polynomial 2x^2 + 3x - 2
    my $P = Math::Polynomial->new(2,3,-2);

    # Evaluate the polynomial for x = 10
    my $result = $P->eval(10);

    # The polynomial 3x + 4
    my $Q = Math::Polynomial->new(3,4);

    print "$P / $Q = ", $P / $Q, "\n";

    my $polynomial = Math::Polynomial::interpolate(1 => 5, 2 => 12, 3 => 6);

=head1 DESCRIPTION

This module implements single variable polynomials using arrays. It also
implements some useful functionality when working with polynomials, such
as adding, multiplication, etc.

=head1 CONSTRUCTOR

The following constructors exist to create new polynomials.

=over 4

=item new(I<coefficient>, ...)

A new polynomial is constructed. The coefficient for the highest degree
term is first in the list, while the constant (the coefficient for
X**0) is the last one in the list.

=cut

sub new {
    my $class = shift;
    my $self = [@_];
    return bless $self, $class;
}

=back

=head1 CLASS METHODS

Here is a list of class methods available. The methods can be applied
to individual polynomials or C<Math::Polynomial>. If it is applied to an
object it will affect the entire class.

=over 4

=item configure(I<variable> => I<value>, ...)

Configure various things regarding the class. Following is a list of
variables used by the class.

=over 4

=item PLUS

The string inserted as a plus sign between terms.
Default is C<' + '>.

=item MINUS

The string inserted as a minus sign between terms. If the first
coefficient is negative, this string without spaces is used as prefix.
Default is C<' - '>.

=item TIMES

The string inserted as multiplication between the coefficients and the
variables. Default is C<'*'>.

=item POWER

The string inserted as power between the variable and the
power. Default is C<'**'>.

=item VARIABLE

The string used as variable in the polynom. Default is C<'$X'>.

=back

=cut

my %CONFIG = (PLUS => ' + ',
	      MINUS => ' - ',
	      TIMES => '*',
	      POWER => '**',
	      VARIABLE => '$X');

sub configure {
    my $class = shift;
    my ($key, $value);

    while (defined ($key = shift) && defined ($value = shift)) {
	$CONFIG{$key} = $value;
    }
}

=item verbose(I<bool>)

If verbose is turned on, string conversion will return a string for
the polynomial, otherwise a list of coefficients will be returned.

=cut

my $VERBOSE = 0;

sub verbose {
    my $class = shift;
    $VERBOSE = shift;
}

=back

=head1 OBJECT METHODS

Here is a list of object methods available. Object methods are applied
to the object in question, in contrast with class methods which are
applied to a class.

=over 4

=item clone()

This method will clone the polynomial and return a copy of it.

=cut

sub clone {
    my $self = shift;
    return Math::Polynomial->new(@$self);
}

=item coeff(I<degree>)

This method returns the coefficient for x to the power of I<degree>.

=cut

sub coeff {
    my $self = shift;
    my $no = shift;
    croak "coeff: exponent out of range "
	unless $no < @$self && $no >= 0;
    return +$self->[@$self - $no - 1];
}

=item degree()

This method returns the degree of the polynomial. The degree of a
polynomial is the maximum of the degree of terms with non-zero
coefficients.  For zero polynomials, B<-1> is returned.

=cut

sub degree {
    my $self = shift;
    my $degree = @$self;
    $degree-- while $degree > 0 && $self->[@$self - $degree] == 0;
    return $degree-1;
}

=item eval(I<value>)

The polynomial is evaluated for I<value>. The evaluation is done using
B<Horners rule>, hence evaluation is done in I<O(n)> time, where I<n>
is the degree of the polynomial.

=cut

sub eval {
    my $self = shift;
    my $arg = shift;
    my $result = 0;
    foreach (@$self) {
	$result = $arg * $result + $_;
    }
    return $result;
}

=item size()

This method returns the internal size of the polynomial, i.e. the
length of the array where the coefficients are stored. After a
C<tidy()>, I<degree> is equal to I<size>-1.

=cut

sub size {
    my $self = shift;
    return scalar @$self;
}

=item tidy()

This method removes all terms which are redundant, i.e. the
zero coefficients where all higher degree coefficients are also zero.

This method is B<never> called automatically, since it is assumed that
the programmer knows best when to tidy the polynomial.

=back

=cut

sub tidy {
    my $self = shift;
    while (@{$self} && 0 == $self->[0]) {
	shift @{$self};
    }
}

=head1 OPERATORS

There is a set of operators defined for polynomials.

=over 4

=item I<polynomial> + I<polynomial>

Adds two polynomials together, returning the sum. The operation is
I<O(n)>, where I<n> is the maximum of the degrees of the polynomials.

=cut

sub plus {
    my $left = shift;
    my $right = shift;
    my $new = Math::Polynomial->new();

    # If adding a constant, turn it into a polynomial
    $right = ref($right) ? $right : Math::Polynomial->new($right);

    my $i = @$left;
    my $j = @$right;

    while ($i > 0 || $j > 0) {
	unshift(@$new, 0);
	$new->[0] += $left->[$i] if $i-- > 0;
	$new->[0] += $right->[$j] if $j-- > 0;
    }
    return $new;
}

=item I<polynomial> - I<polynomial>

Substracts the right polynomial from the left polynomial, returning
the difference. The operation is I<O(n)>, where I<n> is the maximum of
the degrees of the polynomials.

=cut

sub minus {
    my $left = shift;
    my $right = shift;

    # If substracting a constant, turn it into a polynomial
    $right = ref($right) ? $right : Math::Polynomial->new($right);

    # Swap terms if called in reverse order.
    ($right,$left) = ($left,$right) if $_[0];

    my $i = @$left;
    my $j = @$right;
    my $new = Math::Polynomial->new();

    while ($i > 0 || $j > 0) {
	unshift(@$new, 0);
	$new->[0] += $left->[$i] if $i-- > 0;
	$new->[0] -= $right->[$j] if $j-- > 0;
    }
    return $new;
}

=item - I<polynomial>

Negates a polynomial. The operation is I<O(n)> where I<n> is the degree
of the polynomial.

=cut

sub neg {
    my $polynomial = shift;

    return Math::Polynomial->new(map { -$_ } @$polynomial);
}

=item I<polynomial> * I<polynomial>

Multiplies two polynomials together, returning the product. The
operation is I<O(n*m)>, where I<n> and I<m> are the degrees of the
polynomials respectively.

=cut

sub times {
    my $left = shift;
    my $right = shift;
    my $new = Math::Polynomial->new();

    # If multiplied by a constant, turn it into a polynomial
    $right = ref($right) ? $right : Math::Polynomial->new($right);

    for (my $i = 0 ; $i < @$right ; $i++) {
	for (my $j = 0 ; $j < @$left ; $j++) {
	    $new->[$i + $j] += $right->[$i] * $left->[$j];
	}
    }

    return $new;
}

=item I<polynomial> / I<polynomial>

Divides the polynomial on the left (called the numerator) with the
polynomial on the right (called the denominator) and returns the
quotient. If the degree of the denominator is greater than the degree
of the numerator, the zero polynomial will be returned.

The denominator must not be the zero polynomial.

=item I<polynomial> % I<polynomial>

Divides the polynomial on the left (called the numerator) with the
polynomial on the right (called the denominator) and returns the
remainder of the division. If the degree of the denominator is greater
than the degree of numerator, the numerator will be returned.

The denominator must not be the zero polynomial.

=item String conversion.

If verbose is turned on, the polynomial will be converted to a string
where '$X' is used as the variable. If a coefficient is zero, that
term will not be printed.

To change the string used as variable, use the C<configure> class
method described above.

If verbose is turned off, a parenthesised, $"-separated list will be
returned.

=back

=cut

sub to_string {
    my $self = shift;

    if ($VERBOSE) {
	my @terms;
	my $exp = @$self - 1;
	foreach (@$self) {
	    # If the coefficient is not zero...
	    if ($_ != 0) {
		# ... we're going to build a term.
		my $term = '';
		# First, we add a plus or a minus, depending on the
		# sign of the coefficient, then we add the absolute
		# value of the coefficient.
		if ($_ < 0) {
		    push(@terms, $CONFIG{MINUS});
		    $term = -$_ unless $_ == -1 && $exp != 0;
		} else {
		    push(@terms, $CONFIG{PLUS});
		    $term = $_ unless $_ == 1 && $exp != 0;
		}

		# If the exponent is not zero, we append the
		# equivalent of '*x^e' to the result.
		if ($exp != 0) {
		    $term .= $CONFIG{TIMES} if $_ != 1;
		    $term .= $CONFIG{VARIABLE};
		    $term .= $CONFIG{POWER}.$exp if $exp > 1;
		}
		push(@terms,$term);
	    }
	    $exp--;
	}

	if (@terms && $terms[0] eq $CONFIG{PLUS}) {
	    # If there's a plus first, drop it.
	    shift(@terms);
	} elsif (@terms) {
	    # Otherwise, remove any spaces around the first minus.
	    $terms[0] =~ tr/ //d;
	}
	return join('', @terms);
    } else {
	return $self->dump();
    }
}

=head1 SUBROUTINES

=over 4

=item quotrem(I<numerator>,I<denominator>)

This method computes the quotient and the remainder when dividing
I<numerator> by I<denominator> and returns a list
(I<quotient>,I<remainder>). It is used by the operators C</> and C<%>.

It uses the standard long division algorithm for polynomials, with a
complexity of I<O(n*m)> where I<n> and I<m> are the degrees of the
polynomials.

=cut

sub quotrem {
    my $left = shift;
    my $right = shift;

    # If divided by a constant, turn the constant into a polynomial.
    $right = ref($right) ? $right : Math::Polynomial->new($right);

    # Swap terms if called in reverse order.
    ($right,$left) = ($left,$right) if $_[0];

    if (@{$right} && 0 == $right->[0]) {
	$right = $right->clone;
	$right->tidy;
    }
    if (!@{$right}) {
	croak "division by zero polynomial";
    }
    if (@{$left} && 0 == $left->[0]) {
	$left = $left->clone;
	$left->tidy;
    }

    if (@$left >= @$right) {
	my @C = @$left;
	my @R = splice(@C,0,@$right-1);
	my @Q;

	foreach my $C (@C) {
	    push(@R, $C);
	    my $quote = shift(@R) / $right->[0];
	    my $i = 1;
	    foreach (@R) {
		$_ -= $quote * $right->[$i++];
	    }
	    push(@Q, $quote);
	}
	return (
	      Math::Polynomial->new(@Q),
	      Math::Polynomial->new(@R));
    } else {
	return (
	      Math::Polynomial->new(),
	      Math::Polynomial->new(@$left));
    }
}

=item interpolate(I<x> => I<y>, ...)

Given a set of pairs of I<x> and I<y> values, C<interpolate> will
return a polynomial which interpolates those values. The data points
are supplied as a list of alternating I<x> and I<y> values.

The degree of the resulting polynomial will be one less than the
number of pairs, e.g. the polynomial in the synopsis will be of
degree 2.

The interpolation is done using B<Lagrange's formula> and the
implementation runs in I<O(n^2)>, where I<n> is the number of pairs
supplied to C<interpolate>.

Please note that it is a I<bad idea> to use interpolation for
extrapolation, i.e. if you are interpolating a polynomial for
I<x>-values in the range 0 to 10, then you may get terrible results if
you try to predict I<y>-values outside this range. This is true
especially if the true function is not a polynomial.

=cut

# Matching extra ' above.

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

=back

=head1 INTERNAL METHODS

The methods in this section are internal and should not acually be
used for anything but internal stuff. They are documented here anyway,
but beware that these methods may change or dissapear without notice!

=over 4

=item dump()

Returns a compact, but human readable, string representing the object.

=cut

sub dump {
    my $self = shift;
    return "(" . join($",@$self). ")";
}

=item mul1c(I<c>)

Multiply the polynomial by I<(x - c)>. Used internally by the
interpolate() function.

=cut

sub mul1c {
    my $self = shift;
    my $const = - shift;
    my $prev = 0;
    my $tmp;
    push(@$self,0);
    foreach (@$self) {
	$tmp = $_;
	$_ += $const * $prev;
	$prev = $tmp;
    }
}

=item div1c(I<c>)

Divide the polynomial by I<(x - c)>. Used internally by the
interpolate() function.

=back

=cut

sub div1c {
    my $self = shift;
    my $const = - shift;
    my $prev = 0;
    foreach (@$self) {
	$_ -= $prev * $const;
	$prev = $_;
    }
    pop(@$self);
}

=head1 EXPORTS

Math::Polynomial exports nothing by default.
Subroutines that can be exported on demand are:

=over 4

=item quotrem

=item interpolate

=back

=head1 DIAGNOSTICS

Division and modulus operators as well as quotrem() will die on zero
polynomials as right hand operand.

The coeff() method will die on exponents outside the range from zero up to
the current internal size of the coefficient vector minus one.  The range
of allowed exponents will always include the polynomial degree, though.

All other methods are supposed to always be successful.

=head1 CAVEATS

Most methods do not actively check their parameters.  Arithmetic is
carried out using Perl's builtin numeric data types and therefore prone
to rounding errors and occasional floating point exceptions.

=head1 SEE ALSO

Pages in category I<Polynomials> of Wikipedia.

=head1 AUTHORS

Currently maintained by Martin Becker E<lt>becker-cpan-mp@cozap.comE<gt>.

Originally written by Mats Kindahl E<lt>mats@kindahl.netE<gt>.

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2007 Martin Becker E<lt>becker-cpan-mp@cozap.comE<gt>.
All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.  See L<perlartistic>.

This module is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

1;
