# Source this to point the test suite (and mutant) at the local PG container:
#   source db-env.sh
#
# Matches bin/postgres (image postgres:18, user postgres / password password,
# 127.0.0.1:5432). DB is load-bearing for `bundle exec` since the Gemfile picks
# DB gems from $DB.
export DB=postgresql
export DB_HOST=127.0.0.1
export DB_USERNAME=postgres
export DB_PASSWORD=password
