package Konfa::TestReadVariables;
use Test::Class::Most parent => 'Konfa::TestBase';

sub startup : Tests(startup) {
  shift->next::method;

  MyTestConfig->init_with_env;
}

sub test_get_string : Test(1) {
  is(MyTestConfig->get('my_string'), 'the string');
}

sub test_values_are_strings : Test(1) {
  is(MyTestConfig->get('my_number'), '10');
}

sub test_refs_are_stringified : Test(2) {
  like(MyTestConfig->get('my_ref'), qr/^ARRAY\(0x[a-f0-9]+\)$/);
  is(ref(MyTestConfig->get('my_ref')), '');
}

sub test_undef_not_stringified : Test(1) {
  is(MyTestConfig->get('no_default'), undef);
}

sub test_true_values : Test(4) {
  foreach my $truthy (qw(1 yes on true)) {
    MyTestConfig->_store('my_truthy', $truthy);
    is(MyTestConfig->true('my_truthy'), 1, "$truthy is true");
  }
}

sub test_false_values : Test(6) {
  foreach my $falsy (qw(0 no off false blah)) {
    MyTestConfig->_store('my_falsy', $falsy);
    is(MyTestConfig->true('my_falsy'), 0, "$falsy is false");
  }
  MyTestConfig->_store('my_falsy', undef);
  is(MyTestConfig->true('my_falsy'), 0, "undef is false");
}

sub test_get_undeclared_value : Test(1) {
  throws_ok {
    MyTestConfig->get('four_oh_four');
  } qr/variable not found/, 'dies if variable does not exist';
}

sub test_dump : Test(1) {
  cmp_deeply(
    MyTestConfig->dump, {
      my_string  => 'the string',
      my_number  => 10,
      no_default => undef,
      my_truthy  => 'yes',
      my_falsy   => 'no',
      my_ref     => re(qr/^ARRAY\(0x[0-9a-f]+\)$/),
    }
  );
}

sub test_dump_copy : Test(3) {
  my $d = MyTestConfig->dump;
  isnt(MyTestConfig->dump, $d, 'Dump returns a copy');
  isnt(MyTestConfig->dump, MyTestConfig->dump);

  $d->{my_string} = 'changed in copy';
  isnt(MyTestConfig->get('my_string'), $d->{my_string}, 'dumped hash not related to internal konfa data');
}

1;
