# frozen_string_literal: true

require 'solidus_dev_support/rake_tasks'
SolidusDevSupport::RakeTasks.install

require 'solidus_i18n'
namespace :solidus_i18n do
  desc 'Update by retrieving the latest Solidus locale files'
  task update_default: :environment do
    require 'open-uri'
    puts 'Fetching latest Solidus locale file'
    location = 'https://raw.github.com/solidusio/solidus/master/core/config/locales/en.yml'

    File.write("#{locales_dir}/en.yml", URI.parse(location).read)
  end

  def locales_dir
    File.join File.dirname(__FILE__), 'config/locales'
  end
end

task default: 'extension:specs'
