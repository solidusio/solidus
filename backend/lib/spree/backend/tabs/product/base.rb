# frozen_string_literal: true

module Spree
  module Backend
    module Tabs
      class Product
        class Base
          attr_reader :view_context, :current

          def initialize(view_context:, current: nil)
            @view_context = view_context
            @current = current
          end

          def name
            raise NotImplementedError
          end

          def presentation
            raise NotImplementedError
          end

          def url
            raise NotImplementedError
          end

          def visible?
            raise NotImplementedError
          end

          def active?
            name == current
          end

          def css_classes
            return 'active' if active?

            ''
          end

          private

          def product
            view_context.assigns["product"]
          end
        end
      end
    end
  end
end
