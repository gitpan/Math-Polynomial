
# Copyright (C) 1997 Matz Kindahl. All rights reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Math::Polynomial;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = ();
# Class methods may be exported.
@EXPORT_OK = qw(quotrem verbose configure);

$VERSION = 0.01;

use Carp;
use strict;

=head1 NAME

Math::Polynomial - Perl class for working with polynomials.

=head1 SYNOPSIS

    use Math::Polynomial;

     # The polynomial 2x^2 + 3x - 2
    my $P = Math::Polynomial->new(2,3,-2);

    # Evaluate the polynomial for x = 10
    my $result = $P->eval(10);

    # The polynomial 3x + 4
    my $Q = Math::Polynomial->new(3,4);

    print "$P / $Q = ", $P / $Q, "\n";

=head1 DESCRIPTION

This module implements single variable polynomials using arrays. It also
implements some useful functionality when working with polynomials, such
as adding, multiplication, etc.

=cut

use overload
    '+' => \&plus,
    '-' => \&minus,
    'neg' => \&negate,
    '*' => \&times,
    '/' => sub { (&quotrem)[0] },
    '%' => sub { (&quotrem)[1] },
    "\"\"" => \&to_string;

=head1 CONSTRUCTOR

The following constructors exist to create new polynomials.

=over 4

=item new(I<coefficient>, ...)

A new polynomial is constructed. The coefficient for the highest degree
term is first in the list, while the constant (the coefficient for
X**0) is the last one in the list.

=cut

sub new ($@) {
    my $class = shift;
    my $self = [@_];
    bless $self,$class;
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

The string inserted as a plus sign between terms. Default is C<' + '>.

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

my %CONFIG = (PLUS => ' + ', TIMES => '*', POWER => '**', VARIABLE => '$X');

sub configure (\@@) {
    my $self = shift;
    my $class = ref($self) || $self;
    my($key, $value);

    while (($key = shift) && ($value = shift)) {
	$CONFIG{$key} = $value;
    }
}

=item quotrem(I<numerator>,I<denominator>)

This method computes the quotient and the remainder when dividing
I<numerator> by I<denominator> and returns a list
(I<quotient>,I<remainder>). It is used by the operators C</> and C<%>.

It uses the B<Euclidian algorithm> for division, hence we have a
complexity of I<O(n*m)> where I<n> and I<m> are the degrees of the
polynomials.

=cut

sub quotrem {
    my $left = shift;
    my $right = shift;

    # If divided by a constant, turn it into a polynomial
    $right = ref($right) ? $right : Math::Polynomial->new($right);

    # Swap terms if called in reverse order.
    ($right,$left) = ($left,$right) if $_[0];

    if (@$left > @$right) {
	my @C = @$left;
	my @R = splice(@C,0,@$right-1);
	my(@Q,$C);

	foreach $C (@C) {
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

=item verbose(I<bool>)

If verbose is turned on, string conversion will return a string for
the polynomial, otherwise a list of coefficients will be returned.

=cut

my $VERBOSE = 0;

sub verbose {
    my $self = shift;
    my $class = ref($self) || $self;
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

This method returns the coefficient for degree I<degree>.

=cut

sub coeff {
    my $self = shift;
    my $no = shift;
    croak "coeff: coefficient out of range "
	unless $no < @$self && $no >= 0;
    return +$self->[@$self - $no - 1];
}

=item degree()

This method returns the degree of the polynomial. The degree of a
polynomial is the maximum of the degree of terms with non-zero
coefficients.

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
coefficients where all higher degree coefficients are zero.

This method is B<never> called automatically, since it is assumed that
the programmer knows best when to tidy the polynomial.

=back

=cut

sub tidy {
    my $self = shift;
    shift(@$self) while $self->[0] == 0;
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
    my $i = @$left;
    my $j = @$right;

    # If adding a constant, turn it into a polynomial
    $right = ref($right) ? $right : Math::Polynomial->new($right);

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

=item I<polynomial> % I<polynomial>

Divides the polynomial on the left (called the numerator) with the
polynomial on the right (called the denominator) and returns the
remainder of the division. If the degree of the denominator is greater
than the degree of numerator, the numerator will be returned.

=cut

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
	my $exp = $self->degree;
	foreach (@$self) {
	    if ($_ != 0) {
		my $term = $_ == 1 ? "" : $_;

		$term .= $CONFIG{TIMES} if $exp > 0 && $_ != 1;
		
		if ($exp > 0) {
		    $term .= $CONFIG{VARIABLE};
		    $term .= $CONFIG{POWER}.$exp if $exp > 1;
		}
		push(@terms,$term);
	    }
	    $exp--;
	}
	return join($CONFIG{PLUS}, @terms);
    } else {
	return $self->dump();
    }
}

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
interpolation package.

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
interpolation package.

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

=head1 COPYRIGHT

Copyright (C) 1997 Matz Kindahl. All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
