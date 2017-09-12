package Konfa::TestInitFromHashRef;
use Test::Class::Most parent => 'Konfa::TestBase';

use MyTestConfig;

sub startup : Tests(startup => 1) {
  shift->next::method;

  throws_ok { MyTestConfig->get('my_string'); } qr/(?i)initialized/, "not yet initialized";
}

sub hashref {
  {
    my_string => 'from hash',
    no_default => 'a value',
    my_truthy => 'no',
  }
}

sub setup : Tests(setup) {
  MyTestConfig->_reset;
  MyTestConfig->init_with_hashref($_[0]->hashref);
}

sub test_variable_set_from_env : Test(1) {
  is(MyTestConfig->get('my_string'), 'from hash');
}

sub test_undef_set_from_env : Test(1) {
  is(MyTestConfig->get('no_default'), 'a value');
}

sub test_boolean_set_from_env : Test(2) {
  is(MyTestConfig->true('my_truthy'),  0, 'true is turned off');
  is(MyTestConfig->false('my_truthy'), 1, 'true really is turned off');
}

sub test_unknown_key : Test(1) {
  my %copy = %{$_[0]->hashref};
  $copy{_unknown_} = 'what is this';

  MyTestConfig->_reset;
  throws_ok {
    MyTestConfig->init_with_hashref(\%copy);
  } qr/variable not found/, 'variable could not be found';
}

1;
