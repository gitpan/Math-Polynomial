# -*- Mode: Perl -*-
 
use ExtUtils::MakeMaker;
use Config;
 
&WriteMakefile(
               'NAME'     => 'Math::Polynomial',
               'LINKTYPE' => '$(INST_PM)',
	       'VERSION_FROM' => './lib/Math/Polynomial.pm',
               'dist'     => { SUFFIX => 'gz', COMPRESS => 'gzip -f' },
               'clean'    => {'FILES' => '*~'},
);
