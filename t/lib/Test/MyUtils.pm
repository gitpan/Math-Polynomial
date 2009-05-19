# Copyright (c) 2008 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# $Id$

package Test::MyUtils;

use 5.006;
use strict;
use base 'Exporter';

our $VERSION      = '0.001';
our @EXPORT       = qw(use_or_bail maintainer_only);

our $DISTRIBUTION = 'Math-Polynomial';

sub _skip_all {
    my ($reason) = @_;
    print "1..0 # SKIP $reason\n";
    exit 0;
}

sub use_or_bail {
    my ($module, $version, @imports) = @_;

    eval "require $module";
    _skip_all("$module not available") if $@;

    eval {
	VERSION $module $version if defined $version;
	package main;
	import $module @imports;
    };
    _skip_all("$module version $version or higher not available") if $@;
}

sub maintainer_only {
    my $env_maint = uc "MAINTAINER_OF_$DISTRIBUTION";
    $env_maint =~ s/\W+/_/g;
    $ENV{$env_maint} or _skip_all("setenv $env_maint=1 to run these tests");
}

1;
__END__
