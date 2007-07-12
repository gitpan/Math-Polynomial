
use Math::Polynomial qw(interpolate);
use FileHandle;

Math::Polynomial->verbose(1);
Math::Polynomial->configure(VARIABLE => 'x');

my $dir = $0 =~ m{^(.*/).*?$} ? $1 : '';
open(FD, "${dir}test.gplot") or die "cannot open test.gplot, stopped";
while (<FD>) {
    push(@V, $1, $2) if /^(\d+)\s*(\d+)/;
}

my $A = interpolate(@V);

close(FD);

open(FD, "|gnuplot");
autoflush FD 1;			#
print FD "plot $A notitle, '${dir}test.gplot' notitle\r\n";
my $x = <>;			# Wait for a return
print FD "quit\r\n";
close(FD);


