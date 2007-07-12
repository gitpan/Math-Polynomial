use Math::Polynomial qw(interpolate);

# Read the contents of 'sample.dat'
open(FD, "sample.dat") or die "open: $!\n";
@L = split(' ', join(' ', <FD>));
close(FD);

$poly = interpolate(@L);

# Make Math::Polynomial output a gnuplot equation
$poly->verbose(1);
$poly->configure(VARIABLE => 'x');

print $poly, "\n";
