# frozen_string_literal: true

require 'rails/generators'

module Solidus
  # @private
  module PaperclipAdapter
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      class_option :set_preferences,
        type: :boolean,
        default: true,
        banner: 'Wheter or not to set the preferences in the initializer for the attachment adapters'

      class_option :app_directory,
        type: :string,
        default: Rails.root,
        hide: true

      class_option :initializer_directory,
        type: :string,
        default: 'config/initializers/',
        hide: true

      class_option :initializer_basename,
        type: :string,
        default: 'spree',
        banner: 'The name of the initializer containing the attachment adapters settings'

      class_option :app_name,
        type: :string,
        default: Rails.application.class.module_parent.name,
        banner: 'The name of the host application'

      def copy_templates
        say_status :template, "Paperclip Adapters", :green
        template 'app/models/spree/image/paperclip_attachment.rb.tt',
          File.join(options[:app_directory], "app/models/#{options[:app_name].underscore}/image/paperclip_attachment.rb")

        template 'app/models/spree/taxon/paperclip_attachment.rb.tt',
          File.join(options[:app_directory], "app/models/#{options[:app_name].underscore}/taxon/paperclip_attachment.rb")
      end

      def replace_paperclip_adapter
        return unless options[:set_preferences] == true

        say_status :preference, "Custom Paperclip Adapters", :green

        gsub_file File.join(options[:app_directory], options[:initializer_directory], "#{options[:initializer_basename]}.rb"),
          "Spree::Image::PaperclipAttachment",
          "#{options[:app_name]}::Image::PaperclipAttachment"

        gsub_file File.join(options[:app_directory], options[:initializer_directory], "#{options[:initializer_basename]}.rb"),
          "Spree::Taxon::PaperclipAttachment",
          "#{options[:app_name]}::Taxon::PaperclipAttachment"
      end
    end
  end
end
