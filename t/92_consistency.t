# Copyright (c) 2008 Martin Becker.  All rights reserved.
# This package is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

# Checking package consistency (version numbers, file names, ...).
# These are tests for the distribution maintainer.

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 92_consistency.t'

use 5.006;
use strict;
use File::Spec;
use File::Basename;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::MyUtils;
use Math::Polynomial 1.000;

sub test {
    my ($n, $ok, $comment) = @_;
    print !$ok && 'not ', "ok $n", defined($comment) && " - $comment", "\n";
}

sub plan {
    my ($n) = @_;
    print "1..$n\n";
}

sub skip {
    my ($from, $to, $reason) = @_;
    print map "ok $_ # SKIP $reason\n", $from..$to;
}

maintainer_only();

$| = 1;
undef $/;

my $README   = 'README';
my $META_YML = 'META.yml';
my $modname  = 'Math::Polynomial';
my $distname = $modname;
$distname =~ s/::/-/g;

my $script_ref_pat = qr{
    ^\s*\#[^\n]*\b
    After\s+\`make\s+install\'\s+it\s+should\s+work\s+as\s+\`perl\s+
    ([\-\w]+\.t)
    \'
}mx;

print "# location of test script: $FindBin::Bin\n";
my $distroot = '.' eq $FindBin::Bin? '..': dirname($FindBin::Bin);

plan(13);

# part 1: version numbers in various places

my $mod_version = '' . $Math::Polynomial::VERSION;

$mod_version = 'undef' if !defined $mod_version;
print "# dist name is $distname\n";
print "# module version is $mod_version\n";
test 1, $mod_version =~ /^\d+\.\d+\z/, 'sane version number';

if ($distroot =~ /\b\Q$distname\E-(\d+\.\d+)(?:-\w+)?\z/) {
    test 2, $mod_version eq $1, 'numbered distro dir matches version';
}
else {
    skip 2, 2, "not running in numbered distro dir";
}

my $readme_file = File::Spec->catfile($distroot, $README);
if (open FILE, "< $readme_file") {
    my $readme = <FILE>;
    close FILE;
    my $found = $readme =~ /^(\S+)\s+version\s+(\d+\.\d+)\n/i;
    test 3, $found, "$README contains distro name and version number";
    if ($found) {
        my ($readme_distname, $readme_version) = ($1, $2);
        print "# $README refers to $readme_distname version $readme_version\n";
	test 4, $readme_distname eq $distname || $readme_distname eq $modname;
	test 5, $readme_version eq $mod_version;
    }
    else {
	skip 4, 5, "unknown $README version";
    }
}
else {
    skip 3, 5, "cannot open $README file";
}

my $metayml_file = File::Spec->catfile($distroot, $META_YML);
if (open FILE, "< $metayml_file") {
    my $metayml = <FILE>;
    close FILE;
    my $found_dist = $metayml =~ /^name:\s+(\S+)$/mi;
    test 6, $found_dist;
    if ($found_dist) {
	test 7, $1 eq $distname, "$META_YML has matching distro name";
    }
    else {
	skip 7, 7, "unknown $META_YML dist name";
    }
    my $found_vers = $metayml =~ /^version:\s+(\S+)$/mi;
    test 8, $found_vers;
    if ($found_dist) {
	test 9, $1 eq $mod_version, "$META_YML has matching version";
    }
    else {
	skip 9, 9, "unknown $META_YML dist name";
    }
}
else {
    skip 6, 9, "cannot open $META_YML file";
}

# part 2: references to filenames

my $files_count       = 0;
my @unreadable_files  = ();
my @missing_filenames = ();
my @wrong_filenames   = ();
foreach my $script_path (glob File::Spec->catfile($FindBin::Bin, '*.t')) {
    ++$files_count;
    my $script_name = basename($script_path);
    if (open FILE, '<', $script_path) {
	my $script = <FILE>;
	close FILE;
        if ($script =~ /$script_ref_pat/) {
	    my $referenced_name = $1;
	    if ($referenced_name ne $script_name) {
		push @wrong_filenames, "$referenced_name vs. $script_name";
	    }
	}
	else {
	    push @missing_filenames, $script_name;
	}
    }
    else {
	push @unreadable_files, $script_name;
    }
}
test 10, $files_count, "found $files_count test scripts";
print "# unreadable: @unreadable_files\n" if @unreadable_files;
test 11, !@unreadable_files, 'test scripts readable';
print "# w/o file names: @missing_filenames\n" if @missing_filenames;
test 12, !@missing_filenames, 'script filenames referenced';
print "# wrong filename referenced: $_\n" foreach @wrong_filenames;
test 13, !@wrong_filenames, 'referenced filenames match script names';

__END__
