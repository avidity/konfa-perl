use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Test::Class::Load "$FindBin::Bin/tests";

Konfa::TestBase->runtests;
