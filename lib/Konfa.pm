package Konfa;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT_OK;
our $_VALUES;

my $RE_TRUE = qr/^\s*(?:1|true|yes|on)\s*$/oi;

sub import {
  my $class = shift;
  return unless(@_);

  my $directive = shift;

  if($directive eq 'vars') {
    my $symbol = $_[0] || 'vars';

    die "$symbol is already defined by $class"
      if($class->can($symbol));

    {
      no strict 'refs';
      require Konfa::Vars; Konfa::Vars->import($class);

      *{$symbol} = sub { 'Konfa::Vars' };
      push(@EXPORT_OK, $symbol);
      __PACKAGE__->export_to_level(1, $class, $symbol);
    };
  }
}


sub allowed_variables { {} }
sub env_variable_prefix { 'APP_' }

sub init_with_env {
  my $class = shift;
  my $prefix = $class->env_variable_prefix || '';
  my $re_var = qr/^$prefix(.+)$/o;

  foreach my $var (keys(%ENV)) {
    next unless $var =~ $re_var;

    $class->_store(lc($1), $ENV{$var});
  }

  $class->dump;
}

sub on_variable_missing {
  my $class = shift;
  my $var   = shift;

  die "Unsupported configuration variable $var";
}

sub get {
  my $class = shift;
  my $var   = shift;

  die "Not initialized"
    unless(defined($_VALUES));

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

sub _configuration { $_VALUES ||= $_[0]->allowed_variables }

sub _store {
  my $class = shift;
  my $var   = shift;
  my $value = shift;

  return $class->on_variable_missing($var)
    unless(exists($class->_configuration->{$var}));

  return $class->_configuration->{$var} = $value;  # FIXME: Stringify unless undef
}


1;
__END__

=pod

=encoding utf-8

=head1 NAME

Konfa - Configuration encapsulation

=head1 SYNOPSIS

  package MyKonfa;

  use base 'Konfa';

  sub env_variable_prefix { 'APP_' }

  sub allowed_variables {
    {
      show_stuff: 'yes',             # You can describe what the variable is for here
      stuff_id: nil,                 # ID of the stuff we're using
      lasers: 'off',
      tasers: 'on',
    }
  }

  1;

  # - elsewhere -

  MyKonfa->init_with_yaml('my_values');
  # - or -
  MyKonfa->init_with_env;

  # - use variables -

  use MyKonfa;

  MyKonfa->get('stuff_id');
  MyKonfa->true('show_stuff');
  MyKonfa->true('nosuchkey');  #  BOOM!

  # - different way -
  use MyKonfa vars => 'cfg';

  cfg->stuff_id;
  cfg->is_show_stuff;   # true/false
  cfg->isnt_show_stuff; # false/true
  cfg->nosuchkey;       #  BOOM!


=head1 DESCRIPTION

=head1 PUBLIC METHODS

=head2 init_with_env

  $config = Konfa->init_with_env;

Initializes configuration with values from the environment. Returns a hashref
with a copy of the values. See L<dump>.

Variables are converted to lower case and stripped of L<env_variable_prefix>
before stored.

=head2 get

  $value = Konfa->get($key);

Returns whatever value is stored for key. Executes and returns
L<on_variable_missing> if the key does not exist.

=head2 true

  $bool = Konfa->true($key);

Just like L<get> but returns C<1> of the value matches any of C<1>, C<yes>,
C<on> or C<true>, otherwise C<0>.

=head2 false

  $bool = Konfa->false($key);

The inverse of L<true>.

=head2 dump

  $hashref = Konfa->dump;

Returns a hashref to a copy of the current configuration values.

=head1 CONFIGURATION METHODS

=head2 allowed_variables

  sub allowed_variables {
    {
      variable => 'default',
      # ...
    }
  }

Should return a hashref of all allowed keys and their defaults. Use C<undef>
if no default value is supplied. Keys not included in this method will cause
initialisation to fail.

=head2 env_variable_prefix

  sub env_variable_prefix { 'MY_PREFIX_' }

Specifies a prefix to scope variables when initialized from the environment.

  sub allowed_variables { { home => '...' }}
  sub env_variable_prefix { 'MY_PREFIX_' }

  # ...

  Konfa->init_from_env;
  Konfa->get('home'); # Returns value of environment variable MY_PREFIX_HOME

=head1 COPYRIGHT

2016 Avidity AB

=head1 LICENSE

=cut