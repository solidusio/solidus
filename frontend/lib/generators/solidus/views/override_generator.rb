# frozen_string_literal: true

require 'rails'
require 'rails/generators'

module Solidus
  module Views
    class OverrideGenerator < ::Rails::Generators::Base
      def self.views_folder
        Spree::Frontend::Engine.root.join('app', 'views', 'spree')
      end

      VIEWS = Dir.glob(views_folder.join('**', '*'))

      desc "Override solidus frontend views in your app. You can either provide single files or complete folders."

      class_option :only,
        type: :string,
        default: nil,
        desc: "Name of file or folder to copy exclusively. Can be a substring."

      source_root views_folder

      def copy_views
        views_to_copy.each do |file|
          next if File.directory?(file)

          dest_file = Pathname.new(file).relative_path_from(source_dir)
          copy_file file, Rails.root.join('app', 'views', 'spree', dest_file)
        end
      end

      private

      def views_to_copy
        if @options['only']
          VIEWS.select do |view|
            Pathname.new(view).relative_path_from(source_dir).to_s.include?(@options['only'])
          end
        else
          VIEWS
        end
      end

      def source_dir
        self.class.views_folder
      end
    end
  end
end
