package Konfa::TestMultipleModules;
use Test::Class::Most parent => 'Konfa::TestBase';


sub startup : Tests(startup) {
  shift->next::method;

  use MyTestFeatures vars => 'features';
  use MyTestConfig vars => 'config';

  $ENV{KONFA_NO_DEFAULT} = 'set for MyTestConfig';
  $ENV{OTHER_NO_DEFAULT} = 'set for MyTestFeatures';

  MyTestFeatures->init_with_env;
  MyTestConfig->init_with_env;
}

sub shutdown : Tests(shutdown) {
  shift->next::method;

  delete $ENV{KONFA_NO_DEFAULT};
  delete $ENV{OTHER_NO_DEFAULT};
}

sub test_use_two_modules_in_parallel : Test(2) {
  is(MyTestFeatures->get('my_string'), 'in features', 'variable from MyTestFeatures');
  is(MyTestConfig->get('my_string'), 'the string', 'variable from MyTestConfig');
}


sub test_use_two_modules_in_parallel_by_symbol : Test(2) {
  is(features->my_string, 'in features', 'variable from MyTestFeatures through symbol');
  is(config->my_string, 'the string', 'variable from MyTestConfig through symbol');
}

sub test_init_multiple_from_env : Test(2) {
  is(MyTestFeatures->get('no_default'), 'set for MyTestFeatures', 'variable from MyTestFeatures from env');
  is(MyTestConfig->get('no_default'), 'set for MyTestConfig', 'variable from MyTestConfig from env');
}

1;
