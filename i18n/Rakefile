require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'spree/testing_support/common_rake'
require 'spree_i18n'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new

task :default => :spec

spec = eval(File.read('spree_i18n.gemspec'))

Gem::PackageTask.new(spec) do |p|
    p.gem_spec = spec
end

desc 'Generates a dummy app for testing'
task :test_app do
  ENV['LIB_NAME'] = 'spree_i18n'
  Rake::Task['common:test_app'].invoke
end

namespace :spree_i18n do

  desc "Update by retrieving the latest Spree locale files"
  task :update_default do
    puts "Fetching latest Spree locale file to #{locales_dir}"
    require "uri"; require "net/https"

    location = "https://raw.github.com/spree/spree/master/core/config/locales/en.yml"
    begin
      uri = URI.parse(location)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      puts "Getting from #{uri}"
      request = Net::HTTP::Get.new(uri.request_uri)
      case response = http.request(request)
        when Net::HTTPRedirection then location = response['location']
        when Net::HTTPClientError, Net::HTTPServerError then response.error!
      end
    end until Net::HTTPSuccess === response

    unless File.directory?(default_dir)
      FileUtils.mkdir_p(default_dir)
    end

    File.open("#{default_dir}/spree_core.yml", 'w') { |file| file << response.body }
  end

  desc "Syncronize translation files with latest en (adds comments with fallback en value)"
  task :sync do
    puts "Starting syncronization..."
    words = composite_keys
    Dir["#{locales_dir}/*.yml"].each do |filename|
      basename = File.basename(filename, '.yml')
      (comments, other) = Spree::I18nUtils.read_file(filename, basename)
      words.each { |k,v| other[k] ||= "#{words[k]}" }  #Initializing hash variable as en fallback if it does not exist
      other.delete_if { |k,v| !words[k] } #Remove if not defined in en locale
      Spree::I18nUtils.write_file(filename, basename, comments, other, false)
    end
  end

  desc "Create a new translation file based on en"
  task :new  do
    unless locale = env_locale
      print "You must provide a valid LOCALE value, for example:\nrake spree:i18:new LOCALE=pt-PT\n"
      exit
    end

    Spree::I18nUtils.write_file "#{locales_dir}/#{locale}.yml", "#{locale}", '---', composite_keys
    print "New locale generated.\n"
    print "Don't forget to also download the rails translation from: http://github.com/svenfuchs/rails-i18n/tree/master/rails/locale\n"
  end

  desc "Show translation status for all supported locales other than en."
  task :stats do
    words = composite_keys
    words.delete_if { |k,v| !v.match(/\w+/) or v.match(/^#/) }

    results = ActiveSupport::OrderedHash.new
    locale = ENV['LOCALE'] || ''
    Dir["#{locales_dir}/*.yml"].each do |filename|
      # next unless filename.match('_spree')
      basename = File.basename(filename, '.yml')

      # next if basename.starts_with?('en')
      (comments, other) = Spree::I18nUtils.read_file(filename, basename)
      other.delete_if { |k,v| !words[k] } #Remove if not defined in en.yml
      other.delete_if { |k,v| !v.match(/\w+/) or v.match(/#/) }

      translation_status = 100 * (other.values.size / words.values.size.to_f)
      results[basename] = translation_status
    end
    puts "Translation status:"
    results.sort.each do |basename, translation_status|
      puts "#{basename}\t-    #{sprintf('%.1f', translation_status)}%"
    end
    puts
  end

  # Returns a composite hash of all relevant translation keys from each of the gems
  def composite_keys
    Hash.new.tap do |hash|
      hash.merge! get_translation_keys("spree_core")
    end
  end

  def get_translation_keys(gem_name)
    (dummy_comments, words) = Spree::I18nUtils.read_file(File.dirname(__FILE__) + "/default/#{gem_name}.yml", "en")
      words
  end

  def locales_dir
    File.join File.dirname(__FILE__), "config/locales"
  end

  def default_dir
    File.join File.dirname(__FILE__), "default"
  end

  def env_locale
    ENV['LOCALE'].presence
  end
end
