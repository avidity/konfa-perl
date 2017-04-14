package MyTestFeatures;

use parent 'Konfa';

our $MISSING_CB;

sub allowed_variables {
  {
    my_string  => 'in features',
    no_default => undef,
  };
}

sub env_variable_prefix { 'OTHER_' }

sub on_variable_missing {
  return $MISSING_CB->(@_) if($MISSING_CB);
  die "missing $_[1]";
}


1;