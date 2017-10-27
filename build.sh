#!/bin/sh

set -e

# Switching Gemfile
set_gemfile(){
  echo "Switching Gemfile..."
  export BUNDLE_GEMFILE="`pwd`/Gemfile"
}

# Target postgresql. Override with: `DB=sqlite bash build.sh`
export DB=${DB:-postgresql}

# Solidus defaults
echo "Setup Solidus defaults"
bundle check || bundle update --quiet

# Solidus API
echo "**************************************"
echo "* Setup Solidus API and running RSpec..."
echo "**************************************"
cd api; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Solidus Backend
echo "******************************************"
echo "* Setup Solidus Backend and running RSpec..."
echo "******************************************"
cd ../backend; set_gemfile; bundle update --quiet; bundle exec rspec spec; bundle exec teaspoon

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
