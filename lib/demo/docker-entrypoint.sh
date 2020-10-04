#!/bin/bash

export RAILS_ENV=development

cd sandbox && \
bundle exec rails s -p 3000 -b '0.0.0.0'