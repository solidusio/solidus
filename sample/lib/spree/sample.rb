# frozen_string_literal: true

require 'thor'
require 'spree_core'

module Spree
  module Sample
    class << self
      def load_sample(file, shell: Thor::Base.shell.new)
        # If file is exists within application it takes precedence.
        if File.exist?(File.join(Rails.root, 'db', 'samples', "#{file}.rb"))
          path = File.expand_path(File.join(Rails.root, 'db', 'samples', "#{file}.rb"))
        else
          # Otherwise we will use this gems default file.
          path = File.expand_path(samples_path + "#{file}.rb")
        end
        # Check to see if the specified file has been loaded before
        unless $LOADED_FEATURES.include?(path)
          shell.say_status :sample, file.titleize
          require path
        end
      end

      private

      def samples_path
        Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'db', 'samples'))
      end
    end
  end
end
