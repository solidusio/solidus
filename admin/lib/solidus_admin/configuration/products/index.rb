# frozen_string_literal: true

require "solidus_admin/container"
require "solidus_admin/container_helper"
require "solidus_admin/column"

module SolidusAdmin
  class Configuration < Spree::Preferences::Configuration
    # Configuration for the products index table
    class Products
      class Index
        class RenderContext
          include ActionView::Helpers::TagHelper
          include SolidusAdmin::ContainerHelper
        end

        NAMESPACE = "products.index"
        private_constant :NAMESPACE

        # @api private
        def initialize(container: SolidusAdmin::Container)
          @container = container
        end

        # Adds a new column to the products index table
        #
        # @return [SolidusAdmin::Column]
        def add(name:, header:, data: nil, renderer: nil)
          args = { name: name, header: header, model_class_name: "Spree::Product" }
                 .tap { _1[:data] = data unless data.nil? }
                 .tap { _1[:renderer] = renderer unless renderer.nil? }
                 .tap { _1[:render_context] = render_context unless renderer.nil? }


          column = Column.new(**args)

          register(name, column) &&
            resolve(name)
        end

        private

        def register(key, column)
          @container.register(
            container_key(key),
            column
          )
        end

        def resolve(key)
          @container.resolve(
            container_key(key)
          )
        end

        def container_key(key)
          "#{NAMESPACE}#{@container.config.namespace_separator}#{key}"
        end

        def render_context
          @render_context ||= RenderContext.new
        end
      end
    end
  end
end
