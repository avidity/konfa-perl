use 5.010002; # NOT 5.8.8 - needed by CPAN testers

use Module::Build;

my $builder = Module::Build
  ->new(
      module_name => 'Konfa',
      license => 'perl',
      create_makefile_pl => 'traditional',
      requires => {
          'perl' => '>= 5.10.2',
          'Test::Class::Most' => '>= 0.08',
        },
   );
$builder->create_build_script;
