package Konfa::TestMultipleModules;
use Test::Class::Most parent => 'Konfa::TestBase';

use MyTestConfig vars => 'config';
use MyOtherConfig vars => 'other';

sub startup : Tests(startup) {
  shift->next::method;

  $ENV{KONFA_NO_DEFAULT} = 'set for MyTestConfig';
  $ENV{OTHER_NO_DEFAULT} = 'set for MyOtherConfig';

  MyOtherConfig->_reset;

  MyOtherConfig->init_with_env;
  MyTestConfig->init_with_env;
}

sub shutdown : Tests(shutdown) {
  shift->next::method;

  delete $ENV{KONFA_NO_DEFAULT};
  delete $ENV{OTHER_NO_DEFAULT};
}

sub test_use_two_modules_in_parallel : Test(2) {
  is(MyOtherConfig->get('my_string'), 'in other', 'variable from MyOtherConfig');
  is(MyTestConfig->get('my_string'), 'the string', 'variable from MyTestConfig');
}


sub test_use_two_modules_in_parallel_by_symbol : Test(2) {
  is(other->my_string, 'in other', 'variable from MyOtherConfig through symbol');
  is(config->my_string, 'the string', 'variable from MyTestConfig through symbol');
}

sub test_init_multiple_from_env : Test(2) {
  is(MyOtherConfig->get('no_default'), 'set for MyOtherConfig', 'variable from MyOtherConfig from env');
  is(MyTestConfig->get('no_default'), 'set for MyTestConfig', 'variable from MyTestConfig from env');
}

1;
