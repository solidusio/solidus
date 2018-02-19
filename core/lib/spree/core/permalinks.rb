# frozen_string_literal: true

module Spree
  module Core
    module Permalinks
      extend ActiveSupport::Concern

      included do
        class_attribute :permalink_options
      end

      module ClassMethods
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
      end

      def generate_permalink
        "#{self.class.permalink_prefix}#{Array.new(self.class.permalink_length){ rand(9) }.join}"
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

ActiveRecord::Base.send :include, Spree::Core::Permalinks
