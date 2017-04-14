package Konfa::TestInitFromEnv;
use Test::Class::Most parent => 'Konfa::TestBase';

my %TEST_ENV = (
  KONFA_MY_STRING => "from env",
  KONFA_MY_TRUTHY => "off",
  KONFA_NO_DEFAULT => "a value",
  MY_VARIABLE => "missing prefix",
);


sub startup : Tests(startup => 1) {
  shift->next::method;
  use MyTestConfig;

  throws_ok { MyTestConfig->get('my_string'); } qr/(?i)initialized/, "not yet initialized";
}

sub setup : Tests(setup) {
  foreach my $key (keys(%TEST_ENV)) {
    $ENV{$key} = $TEST_ENV{$key};
  }

  MyTestConfig->_reset;
  MyTestConfig->init_with_env;
}

sub teardown : Tests(teardown) {
  foreach my $key (keys(%TEST_ENV)) {
    delete($ENV{$key})
  }
}

sub test_base_prefix : Test(1) {
  is(Konfa->env_variable_prefix, 'APP_', 'default prefix');
}

sub test_prefix : Test(1) {
  is(MyTestConfig->env_variable_prefix, 'KONFA_', 'prefix can be overridden');
}

sub test_variable_set_from_env : Test(1) {
  is(MyTestConfig->get('my_string'), 'from env');
}

sub test_undef_set_from_env : Test(1) {
  is(MyTestConfig->get('no_default'), 'a value');
}

sub test_boolean_set_from_env : Test(2) {
  is(MyTestConfig->true('my_truthy'),  0, 'true is turned off');
  is(MyTestConfig->false('my_truthy'), 1, 'true really is turned off');
}

1;
