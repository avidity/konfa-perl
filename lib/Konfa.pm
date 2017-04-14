package Konfa;

use strict;
use warnings;
use parent 'Exporter';

use Carp;

our @EXPORT_OK;
our $VERSION = '0.1.0';

my $RE_TRUE = qr/^\s*(?:1|true|yes|on)\s*$/oi;

sub import {
  my $class = shift;
  return unless(@_);

  my $directive = shift;

  if($directive eq 'vars') {
    my $symbol = $_[0] || 'vars';

    die "$symbol is already defined by $class"
      if($class->can($symbol));

    require Konfa::Vars;

    {
      no strict 'refs';
      *{$symbol} = sub { Konfa::Vars->__call_chain($class) };
    };

    push(@EXPORT_OK, $symbol);
    __PACKAGE__->export_to_level(1, $class, $symbol);
  }
}


sub allowed_variables { {} }
sub env_variable_prefix { 'APP_' }

sub init_with_env {
  my $class = shift;
  my $prefix = $class->env_variable_prefix || '';
  my $re_var = qr/^$prefix(.+)$/;

  foreach my $var (keys(%ENV)) {
    next unless $var =~ $re_var;

    $class->_store(lc($1), $ENV{$var});
  }

  $class->dump;
}

sub on_variable_missing {
  my $class = shift;
  my $var   = shift;

  croak "Unsupported configuration variable $var";
}

sub get {
  my $class = shift;
  my $var   = shift;

  die "Not initialized"
    unless($class->_is_initialized);

  return $class->on_variable_missing($var)
    unless(exists($class->_configuration->{$var}));

  return $class->_configuration->{$var};
}

sub true {
  my $value = shift->get(shift);

  return 0 unless(defined($value));
  return ($value =~ $RE_TRUE) ? 1 : 0;
}

sub false { (shift->true(shift)) ? 0 : 1 }

sub dump { return { %{$_[0]->_configuration} } }


{
  my $_VALUES = {};
  sub _is_initialized { defined($_VALUES->{$_[0]}) }
  sub _configuration { $_VALUES->{$_[0]} ||= $_[0]->allowed_variables }
  sub _reset { $_VALUES->{$_[0]} = undef }
};

sub _store {
  my $class = shift;
  my $var   = shift;
  my $value = (defined($_[0])) ? "$_[0]" : undef;

  return $class->on_variable_missing($var)
    unless(exists($class->_configuration->{$var}));

  $value = "$value" if(defined($value));
  return $class->_configuration->{$var} = $value;
}


1;

__END__

