package Konfa::TestBase;

use Test::Class::Most;

sub startup  : Tests(startup)  {
  require MyTestConfig; MyTestConfig->_reset;
}
sub setup    : Tests(setup)    {}
sub teardown : Tests(teardown) {}
sub shutdown : Tests(shutdown) {}

1;
