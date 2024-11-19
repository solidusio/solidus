# frozen_string_literal: true

task default: :spec

def print_title(gem_name = '')
  title = ["Solidus", gem_name].join(' ').strip
  puts "\n#{'-' * title.size}\n#{title}\n#{'-' * title.size}"
end

def subproject_task(project, task, title: project, task_name: nil)
  task_name ||= "#{task}:#{project}"
  task task_name do
    print_title(title)
    Dir.chdir(project) do
      sh "rake #{task}"
    end
  end
end

%w[spec db:drop db:create db:migrate db:reset].each do |task|
  solidus_gem_names = %w[core api backend sample promotions legacy_promotions]
  solidus_gem_names.each do |project|
    desc "Run specs for #{project}" if task == 'spec'
    subproject_task(project, task)
  end

  desc "Run rake #{task} for each Solidus engine"
  task task => solidus_gem_names.map { |p| "#{task}:#{p}" }
end

desc "Run backend JS specs"
subproject_task("backend", "spec:js", title: "backend JS", task_name: "spec:backend:js")

# Add backend JS specs to `rake spec` dependencies
task spec: 'spec:backend:js'

task test: :spec
task test_app: 'db:reset'

namespace :solidus do
  desc "Report code coverage results for all solidus gems"
  task :coverage, [:formatter] do |_task, args|
    require "simplecov"
    SimpleCov.merge_timeout 3600
    if ENV["COVERAGE_DIR"]
      SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
    end
    if args[:formatter] == "cobertura"
      require "simplecov-cobertura"
      SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
    end
    SimpleCov.result.format!
  end
end
