# -*- Mode: Perl -*-
 
use ExtUtils::MakeMaker;
use Config;
 
$VERSION = 0.01;

&WriteMakefile(
               'NAME'     => 'Math::Polynomial',
               'LINKTYPE' => '$(INST_PM)',
               'VERSION'  => $VERSION,
               'dist'     => { SUFFIX => 'gz', COMPRESS => 'gzip -f' },
               'clean'    => {'FILES' => '*~'},
);
