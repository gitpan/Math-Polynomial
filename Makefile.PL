# -*- Mode: Perl -*-
 
use ExtUtils::MakeMaker;
 
WriteMakefile(
    'NAME'           => 'Math::Polynomial',
    'LINKTYPE'       => '$(INST_PM)',
    'VERSION_FROM'   => './lib/Math/Polynomial.pm',
    'ABSTRACT_FROM'  => './lib/Math/Polynomial.pm',
    'LICENSE'        => 'perl',
    'AUTHOR'         => 'Martin Becker <becker-cpan-mp@cozap.com>',
);
