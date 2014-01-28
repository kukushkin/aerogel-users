# aerogel-users

User management for aerogel CMS.

Provides user models, helpers and routs for user registration, authentication,
roles and access management.

## Usage

In your application's config.ru:
```ruby
require 'aerogel/core'
require 'aerogel/users'

run Aerogel::Application.load
```
