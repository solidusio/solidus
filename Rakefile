require 'rake'
require 'thor/group'
begin
  require 'spree/testing_support/common_rake'
rescue LoadError
  raise "Could not find spree/testing_support/common_rake. You need to run this command using Bundler."
  exit
end

task default: :test

desc "Runs all tests in all Spree engines"
task test: :test_app do
  %w(api backend core frontend sample).each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/#{gem_name}") do
      sh 'rspec'
    end
  end
end

desc "Generates a dummy app for testing for every Spree engine"
task :test_app do
  %w(api backend core frontend sample).each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/#{gem_name}") do
      sh 'rake test_app'
    end
  end
end

desc "clean the whole repository by removing all the generated files"
task :clean do
  rm_f  "Gemfile.lock"
  rm_rf "sandbox"
  rm_rf "pkg"

  %w(api backend core frontend sample).each do |gem_name|
    rm_f  "#{gem_name}/Gemfile.lock"
    rm_rf "#{gem_name}/pkg"
    rm_rf "#{gem_name}/spec/dummy"
  end
end

namespace :gem do
  def version
    require 'spree/core/version'
    Spree.solidus_version
  end

  def for_each_gem
    %w(core api backend frontend sample).each do |gem_name|
      yield "pkg/solidus_#{gem_name}-#{version}.gem"
    end
    yield "pkg/solidus-#{version}.gem"
  end

  desc "Build all solidus gems"
  task :build do
    pkgdir = File.expand_path("../pkg", __FILE__)
    FileUtils.mkdir_p pkgdir

    %w(core api backend frontend sample).each do |gem_name|
      Dir.chdir(gem_name) do
        sh "gem build solidus_#{gem_name}.gemspec"
        mv "solidus_#{gem_name}-#{version}.gem", pkgdir
      end
    end

    sh "gem build solidus.gemspec"
    mv "solidus-#{version}.gem", pkgdir
  end

  desc "Install all solidus gems"
  task install: :build do
    for_each_gem do |gem_path|
      Bundler.with_clean_env do
        sh "gem install #{gem_path}"
      end
    end
  end

  desc "Release all gems to rubygems"
  task release: :build do
    sh "git tag -a -m \"Version #{version}\" v#{version}"

    for_each_gem do |gem_path|
      sh "gem push '#{gem_path}'"
    end
  end
end

desc "Creates a sandbox application for simulating the Spree code in a deployed Rails app"
task :sandbox do
  Bundler.with_clean_env do
    exec("lib/sandbox.sh")
  end
end
