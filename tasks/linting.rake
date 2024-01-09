# frozen_string_literal: true

namespace :lint do
  task :rb do
    ci_options = "-f junit -o '#{__dir__}/../test-results/rubocop-results.xml' " if ENV['CI']

    sh %{bundle exec rubocop -P -f clang #{ci_options}$(git ls-files -co --exclude-standard | grep -E "\\.rb$" | grep -v "/templates/")}
  end

  task :erb do
    sh 'bundle exec erb-format $(git ls-files -co --exclude-standard | grep -E "\.html.erb$") > /dev/null'
  end

  task :js do
    sh 'npx -y eslint $(git ls-files -co --exclude-standard | grep -E "\.js$" | grep -vE "/(vendor|config|spec)/")'
  end
end

task lint: %w[lint:rb lint:erb lint:js]
