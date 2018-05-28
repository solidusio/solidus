# Develop Solidus

If you would like to develop for Solidus and you intend to submit your work as a
pull request, please [read the contributing guidelines][contributing] first.

Getting your Solidus development environment set up is easy. First, clone the
Solidus GitHub repo:

```bash
git clone git://github.com/solidusio/solidus.git
```

Then enter the directory you just downloaded and install Solidus's dependencies:

```bash
cd solidus
bundle install
```

## Create a sandbox application

Solidus is meant to be run within a Rails application. You can create a sandbox
application inside the source directory that you have cloned. This gives you a
typical Solidus store you can use for testing.

By default, the sandbox includes [`solidus_auth_devise`][solidus-auth-devise],
and the generator seeds the database and loads sample data.

```bash
bundle exec rake sandbox
```

You can prepend `DB=mysql` or `DB=postgresql` to the command in order use those
databases instead of the default SQLite 3 database. For example:

```bash
DB=postgresql bundle exec rake sandbox
```

After the sandbox has been generated, you can change into its directory and
start the server:

```
cd sandbox
rails server
```

[contributing]: https://github.com/solidusio/solidus/blob/master/CONTRIBUTING.md
[solidus-auth-devise]: https://github.com/solidusio/solidus_auth_devise

## Testing

Solidus uses [RSpec](http://rspec.info/) for testing. Refer to its documentation
for more information about the testing library.

If you intend to submit your work to Solidus as a pull request, it must pass all
of the Solidus test suites before it is merged. You must also provide new or
updated tests for your features or bug fixes.

We use CircleCI to run tests on all incoming pull requests.

To run the test suites for `solidus_frontend` and `solidus_backend`, you need to
install [ChromeDriver][chromedriver] on your system first.

You can see the build statuses [on our CircleCI status page][circleci].

### Run all Solidus test suites

To execute all of the test specs, run the `build.sh` script at the root of the
Solidus project:

```bash
bash build.sh
```

The `build.sh` script runs using PostgreSQL by default, but it can be overridden
by setting the `DB` environment variable to `DB=sqlite` or `DB=mysql`. For
example:

```bash
DB=mysql bash build.sh
```

Note that this will fail if you have not installed ChromeDriver on your system.

### Run a single test suite

Each gem contains its own test suite. For example, you can run only the
`solidus_core` gem tests within the `/core` directory:

```bash
cd core
bundle exec rspec
```

By default, the tests run against the default SQLite 3 database. You can instead
specify `DB=mysql` or `DB=postgresql` by prepending it to the command:

```bash
DB=postgresql bundle exec rspec
```

### Generate a code coverage report

You can generate a [SimpleCov](https://github.com/colszowka/simplecov) code
coverage report by prepending `COVERAGE=true` to the `rspec` command:

```bash
COVERAGE=true bundle exec rspec
```

## Develop a Solidus extension

You can add additional features to your store using Solidus extensions. A list
of supported extensions can be found at [extensions.solidus.io][extensions].

You can use the [`solidus_cmd`][solidus-cmd] gem if you want to start creating a
new Solidus extension.

[chromedriver]: https://sites.google.com/a/chromium.org/chromedriver/home
[circleci]: https://circleci.com/gh/solidusio/solidus
[extensions]: http://extensions.solidus.io
[solidus-cmd]: https://github.com/solidusio/solidus_cmd
