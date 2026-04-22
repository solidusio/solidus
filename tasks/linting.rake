# frozen_string_literal: true

namespace :lint do
  task :rb do
    if ENV["CI"]
      results_dir = "#{__dir__}/../test-results"
      system "mkdir -p '#{results_dir}'"
      ci_options = "--format 'Standard::Formatter' --format github --format junit --out '#{results_dir}/rubocop-results.xml' "
    end

    cmd = %{bundle exec standardrb #{ci_options}$(git ls-files -co --exclude-standard | grep -E "\\.rb$" | grep -v "/templates/")}
    system(cmd) || exit($?.exitstatus)
  end

  task :erb do
    sh 'bundle exec erb-format $(git ls-files -co --exclude-standard | grep -E "\.html.erb$") > /dev/null'
  end

  task :js do
    sh 'npx -y eslint $(git ls-files -co --exclude-standard | grep -E "\.js$" | grep -vE "/(vendor|config|spec)/")'
  end
end

task lint: %w[lint:rb lint:erb lint:js]
