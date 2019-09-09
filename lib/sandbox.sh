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
  --skip-javascript

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

bundle install --gemfile Gemfile
bundle exec rake db:drop db:create
bundle exec rails g spree:install --auto-accept --user_class=Spree::User --enforce_available_locales=true
bundle exec rails g solidus:auth:install

echo "
This app is intended for test purposes. If you're interested in running
Solidus in production, visit:
https://guides.solidus.io/developers/getting-started/first-time-installation.html 🚀"
