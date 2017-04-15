package MyTestConfig;

use parent 'Konfa';

sub allowed_variables {
  {
    my_string  => 'the string',
    my_number  => 10,
    no_default => undef,
    my_truthy  => 'yes',
    my_falsy   => 'no',
    my_ref     => [1, 2, 3],
  };
}

sub env_variable_prefix { 'KONFA_' }

sub on_variable_missing {
  die "variable not found";
}

sub reset_vars {
  shift->_reset;
}

1;