# Copyright 2016 - 2017 Gunnar Hansson, Avidity AB, All Rights Reserved.

package Konfa::Vars;

use strict;
use warnings;

our $AUTOLOAD;
my  $KONFA_CLASS;

sub __call_chain { $KONFA_CLASS = $_[1]; $_[0] }

sub AUTOLOAD {
  my ($prefix, $var) = $AUTOLOAD =~ /.+::(?:(is|isnt)_)?(.+)$/;
  my $method = ($prefix)
    ? ($prefix eq 'is')
      ? 'true'
      : 'false'
    : 'get'
  ;

  $KONFA_CLASS->$method($var);
}

1;
