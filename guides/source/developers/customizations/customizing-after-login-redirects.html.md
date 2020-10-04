# Customizing After-login Redirects

Standard Solidus installations use the `solidus_auth_devise` gem
in order to provide user authentication. The gem is based on
`Devise`, a very successful authentication gem for Rails.

When the unauthenticated user visits an authentication-protected page, they're
first redirected to the login page, eventually after successful login they're
redirected back to the page they were originally wanting to visit.

Before redirecting the user to the login page, Solidus stores the original URL
that the user wanted to visit into Rails application session cookie, ie.
`session[:spree_return_to]`.

There are some URLs that we need to avoid storing in session, othwewise
inifite-loops would occur after successful authentication.

All of these URLs with a standard  Solidus installation are related to the
authentication process, but you may need to add more, for example because you
added some more authentication URLs.

Solidus uses rules managed by the service object [`Spree::UserLastUrlStorer`][user-last-url-storer]
in order to decide whether the current path should be stored or not. The
default rule is defined in [`Spree::UserLastUrlStorer::Rules::AuthenticationRule`][auth-rule].

In order to add your custom behavior, you can create a new rule:

```ruby
module Spree
  class UserLastUrlStorer
    module Rules
      module FacebookLoginRule
        extend self

        def match?(controller)
          controller.controller_name == "sessions" &&
            action_name == "facebook_login"
        end
      end
    end
  end
end
```

After that, you need to register your new rule module, for example by adding
this line in `config/spree.rb` file:

```ruby
Spree::UserLastUrlStorer.rules << 'Spree::UserLastUrlStorer::Rules::FacebookLoginRule'
```

Please note that, when at least one rule is met (`#match?` returns `true`) then
the current path **is not** stored in the session.

[user-last-url-storer]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/user_last_url_storer.rb
[auth-rule]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/user_last_url_storer/rules/authentication_rule.rb
