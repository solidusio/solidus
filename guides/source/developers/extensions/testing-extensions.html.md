# Testing extensions

Solidus extensions should work with and be tested against multiple versions of
Solidus. This article outlines how Solidus and [the `solidusio-contrib`
extensions][contrib] are tested. Consider it a model as you develop your own
Solidus extensions.

[contrib]: https://github.com/solidusio-contrib

## TravisCI

We usually test our extensions on TravisCI and make use of their [build matrix
feature][build-matrix] to test across multiple Solidus versions. We also test
against multiple databases: MySQL and PostgreSQL.

Solidus extensions should be tested across all versions of Solidus that have not
reached [End of Life](https://solidus.io/blog/2018/01/04/maintenance-eol-policy.html)
including the `master` branch.

Here's an example `.travis.yml` testing versions 2.2 through 2.7 and the
`master` branch:

```yaml
language: ruby
rvm:
  - 2.3.1
env:
  matrix:
    - SOLIDUS_BRANCH=v2.2 DB=postgres
    - SOLIDUS_BRANCH=v2.3 DB=postgres
    - SOLIDUS_BRANCH=v2.4 DB=postgres
    - SOLIDUS_BRANCH=v2.5 DB=postgres
    - SOLIDUS_BRANCH=v2.6 DB=postgres
    - SOLIDUS_BRANCH=v2.7 DB=postgres
    - SOLIDUS_BRANCH=master DB=postgres
    - SOLIDUS_BRANCH=v2.2 DB=mysql
    - SOLIDUS_BRANCH=v2.3 DB=mysql
    - SOLIDUS_BRANCH=v2.4 DB=mysql
    - SOLIDUS_BRANCH=v2.5 DB=mysql
    - SOLIDUS_BRANCH=v2.6 DB=mysql
    - SOLIDUS_BRANCH=v2.7 DB=mysql
    - SOLIDUS_BRANCH=master DB=mysql
```

[build-matrix]: https://docs.travis-ci.com/user/customizing-the-build/#Build-Matrix

## Gemfile

To use the versions of Solidus specified from the TravisCI build matrix, we need
to use those environment variables in the `Gemfile`. Here's an example:

```ruby
source "https://rubygems.org"

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", github: "solidusio/solidus", branch: branch

if branch == 'master' || branch >= "v2.0"
  gem "rails-controller-testing", group: :test
else
  gem "rails", '~> 4.2.7' # workaround for bundler resolution issue
  gem "rails_test_params_backport", group: :test
end

gem 'pg'
gem 'mysql2'

gemspec
```

## Migrations

Directly inheriting from `ActiveRecord::Migration` is deprecated in Rails 5.0.
Starting in 5.1, this is an error.

To be able to support both Rails 5.1 and Rails 4.2 from the same extension, we
use a helper from the [`solidus_support`][solidus-support] gem.

Here is the processing for using the helper:


1. Add a dependency on `solidus_support` in the `.gemspec`.

```ruby
# your_gem.gemspec
s.add_dependency 'solidus_core', ['>= 1.1', '< 3']
s.add_dependency 'solidus_support'
```

2. Require `solidus_support` from the gem's `/lib/your_gem.rb` file.

```ruby
# /lib/your_gem.rb
require 'solidus_core'
require 'solidus_support'
```

3. Replace all occurrences of `ActiveRecord::Migration` in the gem. This would
   be in all of your `db/migrate/*` migration files.

```ruby
class MyAwesomeMigration < SolidusSupport::Migration[4.2]
  ...
end
```

You can replace all of the `ActiveRecord::Migration` occurrences automatically
with `sed`:

```bash
sed -i 's/ActiveRecord::Migration/SolidusSupport::Migration[4.2]/' db/migrate/*.rb
```

[solidus-support]: https://github.com/solidusio/solidus_support

## extensions.solidus.io

You can see a list of Solidus extensions and their test suite statuses at
[extensions.solidus.io][extensions].

If you'd like to have your extension added, [join the Solidus Slack team][slack]
let us know in the [#solidus channel][solidus-channel].

[extensions]: http://extensions.solidus.io
[slack]: http://slack.solidus.io
[solidus-channel]: https://solidusio.slack.com/messages/solidus

## Rails 5 request specs

In Rails 5, the syntax for making requests in tests has changed:

``` ruby
# Pre-Rails 5
get :users, {id: '123'}, { user_id: 1 }

# Rails 5
get :users, params: { id: '123'}, session: { user_id: 1 }
```

To allow both of these in a test suite side by side, we make use of the
[`rails_test_params_backport`][rails-test-params-backport] gem.

This can be fixed automatically using the
[`rails5-spec-converter`][rails5-spec-converter] gem.

[rails-test-params-backport]: https://github.com/zendesk/rails_test_params_backport
[rails5-spec-converter]: https://github.com/tjgrathwell/rails5-spec-converter

