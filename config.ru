# Suggested rackup options: -O Threads=1:1 -p 3000

require 'bundler/setup'
require 'rails'
require 'rails/all'
require 'solidus'

module Paperclip::Storage::InMemory
  FS = Hash.new { raise "image not found" }

  Paperclip.interpolates(:data_uri) do |attachment, style|
    %{data:#{attachment.content_type};base64,#{FS[attachment.path(style)]}}
  end

  def self.extended base
    base.instance_eval do
      @options[:path] = @options[:path].gsub(':rails_root/public/system/', '')
      @options[:url] = ':data_uri'
    end
  end

  def exists?(style_name = default_style)
    FS.key?(path(style_name))
  end

  def flush_writes #:nodoc:
    @queued_for_write.each do |style_name, file|
      FS[path(style_name)] = Base64.encode64(file.read)
      file.rewind
    end
    after_flush_writes # allows attachment to clean up temp files
    @queued_for_write = {}
  end

  def flush_deletes #:nodoc:
    @queued_for_delete.each { |path| FS.delete(path) }
    @queued_for_delete = []
  end

  def copy_to_local_file(style, local_dest_path)
    File.write(local_dest_path, Base64.decode64(FS[path(style)]))
  end
end

module RailsApp
  class Application < Rails::Application
    config.root                                       = __dir__
    config.cache_classes                              = true
    config.eager_load                                 = false
    config.public_file_server.enabled                 = true
    config.public_file_server.headers                 = { 'Cache-Control' => 'public, max-age=3600' }
    config.consider_all_requests_local                = true
    config.action_controller.allow_forgery_protection = false
    config.action_controller.perform_caching          = false
    config.action_dispatch.show_exceptions            = false
    config.action_mailer.perform_deliveries           = false
    config.active_support.deprecation                 = :stderr
    config.secret_key_base                            = '49837489qkuweoiuoqwe'
    config.logger                                     = ActiveSupport::Logger.new(STDOUT)
    config.assets.debug                               = false
    config.assets.digest                              = true
    config.paperclip_defaults                         = { storage: :in_memory, use_timestamp: false }
    config.active_job.queue_adapter                   = :inline

    config.hosts.clear if config.respond_to? :hosts
    config.middleware.delete Rack::Lock

    %w[core frontend backend api].each do |lib|
      config.assets.paths << "#{__dir__}/#{lib}/lib/spree/testing_support/dummy_app/assets/javascripts"
      config.assets.paths << "#{__dir__}/#{lib}/lib/spree/testing_support/dummy_app/assets/stylesheets"
    end

    ActiveRecord::Migrator.migrations_paths =
      Rails.application.migration_railties.flat_map do |engine|
        (engine.paths['db/migrate'] if engine.respond_to?(:paths)).to_a
      end


    load_seeds = -> { $seeds_loaded ||= Spree::Core::Engine.load_seed }
    load_samples = -> { $samples_loaded ||= SpreeSample::Engine.load_samples }

    routes.append do
      mount Spree::Core::Engine, at: '/'
      get '/solidus/seed' => ->(env) { load_seeds.call; [200, {}, ['Solidus seeds loaded']] }
      get '/solidus/samples' => ->(env) { load_seeds.call; load_samples.call; [200, {}, ['Solidus samples loaded']]  }
    end
  end
end

class ApplicationController < ActionController::Base
  private def spree_current_user
    @spree_current_user ||= Spree::LegacyUser.first
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

Spree.user_class = 'Spree::LegacyUser'
Spree.config do |config|
  config.mails_from = "store@example.com"
  config.image_attachment_module = 'Spree::Image::PaperclipAttachment'
  config.taxon_attachment_module = 'Spree::Taxon::PaperclipAttachment'
end

ENV['DATABASE_URL'] = 'sqlite3::memory:?pool=1'

Rails.application.initialize!

# Forces all threads to share the same connection. This is necessary because
# we're using an in-memory db (see https://gist.github.com/josevalim/470808).
class ActiveRecord::Base
  retrieve_connection.tap { |connection| define_singleton_method(:connection) { connection }   }
end

# Migrations
ActiveRecord::Migration.verbose = false
# Prepare the db with a basic spree structure for LegacyUser
ActiveRecord::Base.connection.migration_context.run(:up, '20160101010000_solidus_one_four'.to_i)
ActiveRecord::Tasks::DatabaseTasks.migrate # Complete the migration

Spree::LegacyUser.create!(email: 'admin@example.com')
  .spree_roles << Spree::Role.find_or_create_by!(name: :admin)

warn <<-USAGE
**
* USAGE:
*
*   http://localhost:3000/solidus/seed    => load seed data
*   http://localhost:3000/solidus/samples => loads sample data (also runs seed)
*   http://localhost:3000/admin           => password-less admin area
*
**
USAGE

run Rails.application
