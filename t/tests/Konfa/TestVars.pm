package Konfa::TestVars;
use Test::Class::Most parent => 'Konfa::TestBase';

use MyTestConfig vars => 'the_var';

sub startup : Tests(startup) {
  shift->next::method;
  MyTestConfig->init_with_env;
}

sub test_exported_symbol : Test(1) {
  isa_ok(the_var, 'Konfa::Vars')
}

sub test_access_variable : Test(1) {
  is(the_var->my_string, 'the string', 'access variable as method');
}

sub test_non_existant_variable : Test(1) {
  throws_ok {
    the_var->four_oh_four
  } qr/(?i)variable not found/, 'calls on_variable_missing if var does not exist';
}

sub test_access_true_boolean : Test(3) {
  is(the_var->is_my_truthy,   1, 'is_-prefix on truthy value');
  is(the_var->isnt_my_truthy, 0, 'isnt_-prefix on truthy value');
  is(the_var->my_truthy, 'yes', 'access regular way');
}

sub test_access_false_boolean : Test(3) {
  is(the_var->is_my_falsy,   0, 'is_-prefix on falsy value');
  is(the_var->isnt_my_falsy, 1, 'isnt_-prefix on falsy value');
  is(the_var->my_falsy, 'no', 'access regular way');
}

1;
