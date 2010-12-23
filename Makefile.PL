use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Dancer::Plugin::SporeDefinitionControl',
    AUTHOR              => q{Nicolas Oudard <nicolas@oudard.org>},
    VERSION_FROM        => 'lib/Dancer/Plugin/SporeDefinitionControl.pm',
    LICENSE             => 'perl',
    PL_FILES            => {},
    PREREQ_PM => {
      'Dancer' => 1.3000,
      'Dancer::Plugin' => 0,
      'Dancer::Test' => 0,
      'YAML' => 0,
      'File::Spec' => 0,
      'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Dancer-Plugin-SporeDefinitionControl-*' },
);
