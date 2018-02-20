# frozen_string_literal: true

require 'spree_core'
module Spree
  module Sample
    class << self
      def load_sample(file)
        # If file is exists within application it takes precendence.
        if File.exist?(File.join(Rails.root, 'db', 'samples', "#{file}.rb"))
          path = File.expand_path(File.join(Rails.root, 'db', 'samples', "#{file}.rb"))
        else
          # Otherwise we will use this gems default file.
          path = File.expand_path(samples_path + "#{file}.rb")
        end
        # Check to see if the specified file has been loaded before
        if !$LOADED_FEATURES.include?(path)
          require path
          puts "Loaded #{file.titleize} samples"
        end
      end

      private

      def samples_path
        Pathname.new(File.join(File.dirname(__FILE__), '..', '..', 'db', 'samples'))
      end
    end
  end
end
