package MyKonfa;

use base 'Konfa';


sub get {
  warn "******";
  my $class = shift;
  $class->SUPER::get(@_);
}

sub allowed_variables {
  {
    blah => 'default',
    enabled => 'yes',
    no_default => undef,
    testing => 'ue',
  }
}

1;