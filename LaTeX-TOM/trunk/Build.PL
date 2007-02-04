## Created by make2build 0.17

use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new
  (
   module_name => 'LaTeX::TOM',
   dist_author => 'Aaron Krowne <akrowne@vt.edu.org>',   
   dist_version_from => 'lib/LaTeX/TOM.pm',
   build_requires => { 'Test::More' => 0 },	       
   license => 'perl',
   create_readme => 1,   
   create_makefile_pl => 'traditional',
  );
  
$build->create_build_script;
