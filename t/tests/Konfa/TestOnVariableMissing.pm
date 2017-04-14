package Konfa::TestOnVariableMissing;
use Test::Class::Most parent => 'Konfa::TestBase';


sub startup : Tests(startup) {
  shift->next::method;
  # use MyOtherKonfa vars => 'config';
  # MyOtherKonfa->_reset;
  # MyOtherKonfa->init_with_env;

  # $MyOtherKonfa::MISSING_CB = sub {
  #   is($_[0], 'MyOtherKonfa', 'first argument is class name');
  #   is($_[1], 'four_oh_four', 'second argument is misspelt variable');
  # };
}

#sub test_error_callback : Test(2) {
#  MyOtherKonfa->get('four_oh_four');
#}


1;
