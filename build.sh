#!/bin/sh

set -e

# Switching Gemfile
set_gemfile(){
  echo "Switching Gemfile..."
  export BUNDLE_GEMFILE="`pwd`/Gemfile"
}

# Target postgres. Override with: `DB=sqlite bash build.sh`
export DB=${DB:-postgres}

# Solidus defaults
echo "Setup Solidus defaults and creating test application..."
bundle check || bundle update --quiet
bundle exec rake test_app

# Solidus API
echo "**************************************"
echo "* Setup Solidus API and running RSpec..."
echo "**************************************"
cd api; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Solidus Admin
echo "******************************************"
echo "* Setup Solidus Admin and running RSpec..."
echo "******************************************"
cd ../admin; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Solidus Core
echo "***************************************"
echo "* Setup Solidus Core and running RSpec..."
echo "***************************************"
cd ../core; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Solidus Frontend
echo "*******************************************"
echo "* Setup Solidus Frontend and running RSpec..."
echo "*******************************************"
cd ../frontend; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Solidus Sample
echo "*****************************************"
echo "* Setup Solidus Sample and running RSpec..."
echo "*****************************************"
cd ../sample; set_gemfile; bundle update --quiet; bundle exec rspec spec
