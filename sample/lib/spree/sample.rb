# frozen_string_literal: true

require "thor"
require "spree_core"

module Spree
  module Sample
    class << self
      def load_sample(file, shell: Thor::Base.shell.new)
        # If file is exists within application it takes precendence.
        path = if File.exist?(Rails.root.join("db", "samples", "#{file}.rb").to_s)
          File.expand_path(Rails.root.join("db", "samples", "#{file}.rb").to_s)
        else
          # Otherwise we will use this gems default file.
          File.expand_path(samples_path + "#{file}.rb")
        end
        # Check to see if the specified file has been loaded before
        unless $LOADED_FEATURES.include?(path)
          shell.say_status :sample, file.titleize
          require path
        end
      end

      private

      def samples_path
        Pathname.new(File.join(File.dirname(__FILE__), "..", "..", "db", "samples"))
      end
    end
  end
end
