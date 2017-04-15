package Konfa::TestOnVariableMissing;
use Test::Class::Most parent => 'Konfa::TestBase';

use MyOtherConfig vars => 'config';

sub startup : Tests(startup) {
  shift->next::method;

  MyOtherConfig->_reset;
  MyOtherConfig->init_with_env;

  $MyOtherConfig::MISSING_CB = sub {
    is($_[0], 'MyOtherConfig', 'first argument is class name');
    is($_[1], 'four_oh_four', 'second argument is a missing variable');
  };
}

sub test_error_callback : Test(2) {
  MyOtherConfig->get('four_oh_four');
}

sub test_error_callback_through_symbol : Test(2) {
  config->four_oh_four;
}


1;
