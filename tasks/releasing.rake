# frozen_string_literal: true

require 'bundler/gem_tasks'

SOLIDUS_GEM_NAMES = %w[core api backend sample promotions legacy_promotions]

%w[build install].each do |task_name|
  desc "Run rake #{task} for each Solidus gem"
  task task_name do
    SOLIDUS_GEM_NAMES.each do |gem_name|
      cd(gem_name) { sh "rake #{task_name}" }
    end
  end
end

# We need to redefine release task to skip creating and pushing git tag
Rake::Task["release"].clear
desc "Build and push solidus gems to RubyGems"
task "release" => ["build", "release:guard_clean", "release:rubygem_push"] do
  SOLIDUS_GEM_NAMES.each do |gem_name|
    cd(gem_name) { sh "rake release:rubygem_push" }
  end
end
