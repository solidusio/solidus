# frozen_string_literal: true

module SolidusAdmin
  module TestingSupport
    module ComponentHelpers
      # Mocks a component class with the given definition.
      #
      # @param definition [Proc] the component definition
      # @example
      #  mock_component do
      #    def call
      #      "Rendered"
      #    end
      #  end
      def mock_component(&definition)
        location = caller(1, 1).first
        component_class = Class.new(SolidusAdmin::BaseComponent)
        # ViewComponent will complain if we don't fake a class name:
        # @see https://github.com/ViewComponent/view_component/blob/5decd07842c48cbad82527daefa3fe9c65a4226a/lib/view_component/base.rb#L371
        component_class.define_singleton_method(:name) { "Foo" }
        component_class.define_singleton_method(:to_s) { "#{name} (#{location})" }
        component_class.class_eval(&definition) if definition
        component_class
      end
    end
  end
end
