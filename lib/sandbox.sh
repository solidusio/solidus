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
bundle exec rails new sandbox --skip-bundle --database="$RAILSDB"
if [ ! -d "sandbox" ]; then
  echo 'sandbox rails application failed'
  exit 1
fi

cd ./sandbox
cat <<RUBY >> Gemfile
gem 'solidus', :path => '..'
gem 'solidus_auth_devise', github: 'solidusio/solidus_auth_devise'

gem 'paranoia', github: 'jhawthorn/paranoia', branch: 'rails5'
gem 'state_machines-activerecord', github: 'state-machines/state_machines-activerecord'
gem 'state_machines-activemodel', github: 'state-machines/state_machines-activemodel'
gem 'ransack', github: 'activerecord-hackery/ransack'
gem 'rabl', github: 'nesquena/rabl'

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
