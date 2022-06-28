# Develop Solidus

If you would like to improve Solidus and you intend to submit your work as a
pull request, please [read the contributing guidelines][contributing] first.

Getting your Solidus development environment set up is easy. First, clone the
Solidus GitHub repo:

```bash
git clone git://github.com/solidusio/solidus.git
```

Then enter the directory you just downloaded and install Solidus' dependencies:

```bash
cd solidus
bundle install
```

Alternatively, you can use the [docker setup](#develop-with-docker).

## Create a sandbox application

Solidus is meant to be run within a Rails application. You can create a sandbox
application inside the source directory that you have cloned. This gives you a
typical Solidus store you can use for testing.

By default, the sandbox includes [`solidus_auth_devise`][solidus-auth-devise],
and the generator seeds the database and loads sample data.

```bash
bin/sandbox
```

You can prepend `DB=mysql` or `DB=postgresql` to the command in order use those
databases instead of the default SQLite 3 database. For example:

```bash
env DB=postgresql bin/sandbox
```

After the sandbox has been generated, you can change into its directory and
start the server:

```bash
cd sandbox
bin/rails server
```

If you need to create a Rails 5.2 application for your sandbox, for example
if you are still using Ruby 2.4 which is not supported by Rails 6, you can
use the `RAILS_VERSION` environment variable.

```bash
  export RAILS_VERSION='~> 5.2.0'
  bundle install
  bin/sandbox
```

[contributing]: https://github.com/solidusio/solidus/blob/master/CONTRIBUTING.md
[solidus-auth-devise]: https://github.com/solidusio/solidus_auth_devise

## Testing

Solidus uses [RSpec][rspec] for testing. Refer to its documentation
for more information about the testing library.

If you intend to submit your work to Solidus as a pull request, it must pass all
of the Solidus test suites before it is merged. You must also provide new or
updated tests for your features or bug fixes.

We use CircleCI to run tests on all incoming pull requests.

To run the test suites for `solidus_frontend` and `solidus_backend`, you need to
install [ChromeDriver][chromedriver] on your system first.

You can see the build statuses [on our CircleCI status page][circleci].

[rspec]: http://rspec.info/

### Run all Solidus test suites

To execute all of the test specs, run the `bin/build` script at the root of the
Solidus project:

```bash
bin/build
```

The `bin/build` script runs using PostgreSQL by default, but it can be overridden
by setting the `DB` environment variable to `DB=sqlite` or `DB=mysql`. For
example:

```bash
env DB=mysql bin/build
```

Note that this will fail if you have not installed ChromeDriver on your system.

### Run a single test suite

Each gem contains its own test suite. For example, you can run only the
`solidus_core` gem tests within the `core` directory:

```bash
cd core
bundle exec rspec
```

By default, the tests run against the default SQLite 3 database. You can instead
specify `DB=mysql` or `DB=postgresql` by prepending it to the command:

```bash
env DB=postgresql bundle exec rspec
```

### Generate a code coverage report

You can generate a [SimpleCov][simplecov] code
coverage report by prepending `COVERAGE=true` to the `rspec` command:

```bash
env COVERAGE=true bundle exec rspec
```

[simplecov]: https://github.com/colszowka/simplecov

## Develop a Solidus extension

You can add additional features to your store using Solidus extensions. A list
of supported extensions can be found at [extensions.solidus.io][extensions].

You can use the [`solidus_dev_support`][solidus_dev_support] gem as an example if you want to
start creating a new Solidus extension. Check out the doc on
[writing extensions][writing-extensions] to learn more.

[chromedriver]: https://sites.google.com/a/chromium.org/chromedriver/home
[circleci]: https://circleci.com/gh/solidusio/solidus
[extensions]: http://extensions.solidus.io
[writing-extensions]: https://guides.solidus.io/developers/extensions/writing-extensions.html
[solidus_dev_support]: https://github.com/solidusio/solidus_dev_support

## Develop with docker

If you have docker and docker-compose, you can leverage them to get a
development environment ready to go in a snap:

```bash
docker-compose up -d
```

The `app` service is the one sharing the repository source code. Once the image
has been built, you have to wait for all the dependencies to be installed. This
won't happen in subsequent invocations. You can check progress through the
service's logs:

```bash
docker-compose logs -f app
```

The image can be built with other ruby versions through the `RUBY_VERSION` build argument:

```bash
docker-compose build --build-arg RUBY_VERSION=2.7 app
docker-compose up -d
```

In addition, the rails version can also be set on container initialization
through the `RAILS_VERSION` environment variable:

```bash
RAILS_VERSION='~> 5.0' docker-compose up -d
```

You can use either postgres, mysql or sqlite to run the test suite:

```bash
# sqlite
docker-compose exec app bin/rspec
# postgres
docker-compose exec app env DB=postgres bin/rspec
# mysql
docker-compose exec app env DB=mysql bin/rspec
```

Database engine clients are also available:

```bash
# sqlite
docker-compose exec app sqlite3 /path/to/db
# postgres
docker-compose exec app env PGPASSWORD=password psql -U root -h postgres
# mysql
docker-compose exec app mysql -u root -h mysql -ppassword
```

In order to be able to access the [sandbox
application](#create-a-sandbox-application), just make sure to provide the
appropriate `--binding` option to `rails server`. By default, port `3000` is
exposed, but you can change it through `SANDBOX_PORT` environment variable:

```bash
SANDBOX_PORT=4000 docker-compose up -d
docker-compose exec app bin/sandbox
docker-compose exec app bin/rails server --binding 0.0.0.0 --port 4000
```
