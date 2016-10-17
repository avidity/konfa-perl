package Konfa::Vars;

use strict;
use warnings;

our $AUTOLOAD;
my  $KONFA_CLASS = 'Konfa';

sub import { $KONFA_CLASS = $_[1] }

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