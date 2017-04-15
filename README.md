# Konfa

Perl port of the Ruby [Konfa](https://github/avidity/konfa) configuration interface.

Konfa aims to solve some of the common mishaps related to application configration
such as:

 * Bugs attributed to misspelt configuration variable names
 * Forgotten configuration options that nobody knows what they do or where they are used
 * Seamlessly reading configuration values from either the environment or YAML (or any other source for that matter)

## Usage

```perl

package AppConfig;
use parent 'Konfa';

sub env_variable_prefix { 'APP_' }
sub allowed_variables {
  {
    'api_key' => nil,
    'feature_enabled' => 'yes',
  }
}

# -- Later on --

AppConfig->init_with_env;

# -- Even later --

use AppConfig vars => 'config';

if(config->is_feature_enabled) {
   # do what is needed
}
```
See the [module POD](../master/lib/Konfa.pm) for more examples and API documentation.

# License

This is free software. Like Perl 5, you can redistribute it and/or modify it under the terms of either

 a) the [GNU General Public License](http://dev.perl.org/licenses/gpl1.html);
 
 b) the ["Artistic License"](http://dev.perl.org/licenses/artistic.html). 
 
See [LICENSE](../master/LICENSE) for full license text.

