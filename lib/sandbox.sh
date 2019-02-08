#!/bin/sh
# Used in the sandbox rake task in Rakefile

set -e

case "$DB" in
postgres|postgresql)
  RAILSDB="postgresql"
  ;;
mysql)
  RAILSDB="mysql"
  ;;
sqlite|'')
  RAILSDB="sqlite3"
  ;;
*)
  echo "Invalid DB specified: $DB"
  exit 1
  ;;
esac

rm -rf ./sandbox
bundle exec rails new sandbox --database="$RAILSDB" \
  --skip-bundle \
  --skip-git \
  --skip-keeps \
  --skip-rc \
  --skip-spring \
  --skip-test \
  --skip-yarn

if [ ! -d "sandbox" ]; then
  echo 'sandbox rails application failed'
  exit 1
fi

cd ./sandbox
cat <<RUBY >> Gemfile

gem 'solidus', path: '..'
gem 'solidus_auth_devise', '>= 2.1.0'
gem 'rails-i18n'
gem 'solidus_i18n'

group :test, :development do
  platforms :mri do
    gem 'pry-byebug'
  end
end
RUBY

# Ensure sqlite3 version to match ActiveRecord SQLite adapter requirement
# (see https://github.com/solidusio/solidus/issues/3087 for details)
sed -i -e "s/gem 'sqlite3'/gem 'sqlite3', '~> 1.3.6'/g" Gemfile

bundle install --gemfile Gemfile
bundle exec rake db:drop db:create
bundle exec rails g spree:install --auto-accept --user_class=Spree::User --enforce_available_locales=true
bundle exec rails g solidus:auth:install
