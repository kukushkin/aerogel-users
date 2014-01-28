# Aerogel::Module123

An aerogel module skeleton. Starting point for any generic aerogel module.

This module template includes all folders an aerogel module can use, but none of them are obligatory. For example, if a module does not have any assets, it is perfectly safe to remove assets/* folders.

## Usage

1. Clone repository
2. Rename 'module123' to your module name anywhere
3. Add code, remove unneeded folders

In your application's config.ru:
```ruby
require 'aerogel'
require 'aerogel/module123' # ...change to your module name

run Aerogel::Application.load
```
