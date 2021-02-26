# frozen_string_literal: true

module Spree
  module Core
    module Permalinks
      extend ActiveSupport::Concern

      included do
        class_attribute :permalink_options
      end

      class_methods do
        def make_permalink(options = {})
          options[:field] ||= :permalink
          self.permalink_options = options

          before_validation(on: :create) { save_permalink }
        end

        def find_by_param(value, *args)
          send("find_by_#{permalink_field}", value, *args)
        end

        def find_by_param!(value, *args)
          send("find_by_#{permalink_field}!", value, *args)
        end

        def permalink_field
          permalink_options[:field]
        end

        def permalink_letters
          permalink_options[:letters]
        end

        def permalink_model
          permalink_options[:model]
        end

        def permalink_prefix
          permalink_options[:prefix] || ""
        end

        def permalink_length
          permalink_options[:length] || 9
        end

        def permalink_order
          order = permalink_options[:order]
          "#{order} ASC," if order
        end

        def number_generator
          Spree::Core::NumberGenerator.new(
            prefix: permalink_prefix,
            length: permalink_length,
            letters: permalink_letters,
            model: permalink_model
          )
        end
      end

      def generate_permalink
        self.class.number_generator.generate
      end

      def save_permalink(permalink_value = to_param)
        permalink_value ||= generate_permalink
        permalink_field = self.class.permalink_field

        loop do
          other = self.class.where(permalink_field => permalink_value)
          break unless other.exists?

          # Try again with a new value
          permalink_value = generate_permalink
        end
        write_attribute(permalink_field, permalink_value)
      end
    end
  end
end
