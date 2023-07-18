# frozen_string_literal: true

require 'solidus_admin/configuration/products/index'

module SolidusAdmin
  class Configuration < Spree::Preferences::Configuration
    class Products
      def index
        (@index ||= Index.new).tap do
          yield(_1) if block_given?
        end
      end
    end
  end
end
