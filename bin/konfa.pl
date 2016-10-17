use strict;
use warnings;
use feature ':5.22';

use MyKonfa vars => 'v';


MyKonfa->init_with_env;

say v->testing;
say v->enabled;
say v->is_enabled;
say v->isnt_enabled;


say MyKonfa->get('blah');



