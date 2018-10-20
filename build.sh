#!/bin/sh

set -e

# Target postgresql. Override with: `DB=sqlite bash build.sh`
export DB=${DB:-postgresql}

# Solidus defaults
echo "Installing Solidus test dependencies"
bundle check || bundle update --quiet

# Solidus API
echo "***********************"
echo "* Testing Solidus API *"
echo "***********************"
cd api
bundle exec rspec spec

# Solidus Admin
echo "***************************"
echo "* Testing Solidus Admin *"
echo "***************************"
cd ../admin
bundle exec rspec spec
bundle exec teaspoon

# Solidus Core
echo "************************"
echo "* Testing Solidus Core *"
echo "************************"
cd ../core
bundle exec rspec spec

# Solidus Frontend
echo "****************************"
echo "* Testing Solidus Frontend *"
echo "****************************"
cd ../frontend
bundle exec rspec spec

# Solidus Sample
echo "**************************"
echo "* Testing Solidus Sample *"
echo "**************************"
cd ../sample
bundle exec rspec spec
