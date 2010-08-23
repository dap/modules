## Created by make2build 0.17

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new
  (
   module_name => 'Tie::DiskUsage',
   dist_author => 'Steven Schubiger <schubiger@cpan.org>',
   dist_version_from => 'lib/Tie/DiskUsage.pm',
   requires => {
                 'Carp' => 0,
                 'Cwd' => 0,
                 'File::Which' => 0,
                 'Symbol' => 0,
                 'Tie::Hash' => 0,
               },
   build_requires => {
                       'File::Spec' => 0,
                       'File::Temp' => 0,
                       'Test::More' => 0,
                     },
   recommends => {
                   'Test::Pod' => '1.14',
                   'Test::Pod::Coverage' => '1.04',
                 },
   license => 'perl',
   create_readme => 1,
   create_makefile_pl => 'traditional',
  );

$build->create_build_script;
