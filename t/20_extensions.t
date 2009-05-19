# Copyright (c) 2007-2008 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 20_extensions.t'

#########################

use strict;
use Test;
BEGIN { plan tests => 1 };
use Math::Polynomial 1.000;
ok(1);

#########################

__END__
20_extensions.t:

