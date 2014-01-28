# Aerogel::Module123

An aerogel module skeleton. Starting point for any generic aerogel module.

This module template includes all folders an aerogel module can use. None of these folders are obligatory and can be omitted from final module.

## Usage

1. Clone repository
2. Rename 'module123' to your module name anywhere
3. Add code, remove unneeded folders

In your application's config.ru:
```ruby
require 'aerogel'
require 'aerogel/module123' # ...change to your module name

run Aerogel::Application
```
