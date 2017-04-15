package Konfa;

use strict;
use warnings;
use parent 'Exporter';

use Carp;

our @EXPORT_OK;
our $VERSION = '0.001';

my $RE_TRUE = qr/^\s*(?:1|true|yes|on)\s*$/oi;

sub import {
  my $class = shift;
  return unless(@_);

  my $directive = shift;

  if($directive eq 'vars') {
    my $symbol = $_[0] || 'vars';

    require Konfa::Vars;

    {
      no warnings 'redefine';
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
  sub _configuration { $_VALUES->{$_[0]} ||= $_[0]->_init_default }
  sub _reset { $_VALUES->{$_[0]} = undef }
};

sub _store {
  my $class = shift;
  my $var   = shift;
  my $value = (defined($_[0])) ? "$_[0]" : undef;

  return $class->on_variable_missing($var)
    unless(exists($class->_configuration->{$var}));

  return $class->_configuration->{$var} = $value;
}

sub _init_default {
  my %copy = %{shift->allowed_variables};
  foreach my $key (keys(%copy)) {
    $copy{$key} = "$copy{$key}" if(ref($copy{$key}));
  }

  return \%copy;
}


1;

__END__

=pod

=encoding utf-8

=head1 NAME

Konfa - Configuration encapsulation

=head1 SYNOPSIS

  package MyKonfa;

  use parent 'Konfa';

  sub env_variable_prefix { 'MY_APP_' }

  sub allowed_variables {
    {
      show_stuff => 'yes',             # You can describe what the variable is for here
      stuff_id   => undef,             # ID of the stuff we're using
      lasers     => 'off',
      tasers     => 'on',
    }
  }

  1;

  # - elsewhere -

  MyKonfa->init_with_env;

  # - use variables -

  use MyKonfa;

  MyKonfa->get('stuff_id');
  MyKonfa->true('show_stuff'); # Bool
  MyKonfa->get('show_stuff');  # String
  MyKonfa->true('nosuchkey');  #  BOOM!

  # - or -

  use MyKonfa vars => 'cfg';

  cfg->stuff_id;
  cfg->is_show_stuff;   # true/false
  cfg->isnt_show_stuff; # false/true
  cfg->nosuchkey;       #  BOOM!


=head1 DESCRIPTION

Konfa is derived from its Ruby namesake, developed by Avidity AB that is
available here:.

Konfa aims to solve some of the common mishaps related to application configration
such as:

=over 4

=item Bugs attributed to misspelt configuration variable names

=item Forgotten configuration options that nobody knows what they do or where they are used

=item Seamlessly reading configuration values from either the environment or YAML (or any other source for that matter)

=back

=head2 VALUES

For the sake of simplicity and compatability with configuration values consumed
from various sources, values are always stringified. This means that hashes and
arrays are not supported out of the box, but can be implemented like this:


  package MyKonfa
  use parent Konfa

  sub allowed_variables {
    {
      names => 'gunnar, simone, cabelinho'
    }
  }

  sub as_list {
    my ($class, $key) = shift;

    return [split(/\s*,\*/, $class->get($key))];
  }

  MyKonfa->get('names');     # "gunnar, simone, cabelinho"
  MyConfa->as_list('names'); # ["gunnar","simone","cabelinho"]

=head2 BOOLEANS

The C<true> and C<false> methods can help you use a value as a boolean. The
following values are interpreted as true:

=over

=item C<"on">

=item C<"1">

=item C<"yes">

=item C<"true">

=back

As a consequence, any other value is considered false. The original value can be
accessed through C<get>.

=head1 API

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

These methods should be implemented by the configuration class

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
  Konfa->get('home'); # Returns value of environment variable C<MY_PREFIX_HOME>

=head2 on_variable_missing

  sub on_variable_missing {
    my ($class, $variable_name) = @_;
    ...
  }

This method will be called by Konfa when attempting to retrieve or store a
configuration value using a key not defined in C<allowed_variables>.

The default behaviour is to C<croak>.

=head1 LICENSE

Copyright 2016 - 2017 Gunnar Hansson, Avidity AB, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
