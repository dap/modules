# Note: this file has been initially created by Module::Build::Convert 0.21

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new
  (
   module_name => 'Math::Factor::XS',
   dist_author => 'Steven Schubiger <schubiger@cpan.org>',
   dist_version_from => 'lib/Math/Factor/XS.pm',   
   requires => {
                 'Exporter' => 0,
		 'XSLoader' => 0,
               },
   build_requires => { 'Test::More' => 0 },	       
   recommends => {
                   'Test::Pod' => '1.14',
		   'Test::Pod::Coverage' => '1.04',
		 },
   xs_files => { 'XS.xs' => 'blib/Math/Factor/XS.xs' },
   include_dirs => [ '.' ],
   license => 'perl',
   create_readme => 1,
   create_makefile_pl => 'traditional',
  );
  
$build->create_build_script;
