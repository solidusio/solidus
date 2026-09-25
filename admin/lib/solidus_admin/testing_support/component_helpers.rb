# frozen_string_literal: true

module SolidusAdmin
  module TestingSupport
    module ComponentHelpers
      # Renders components through the admin's base controller, so that the
      # admin helpers and layout context are available.
      def vc_test_controller_class
        SolidusAdmin::BaseController
      end

      # Mocks a component class with the given definition.
      #
      # @param definition [Proc] the component definition
      # @example
      #  mock_component do
      #    def call
      #      "Rendered"
      #    end
      #  end
      def mock_component(class_name = "Foo::Component", &definition)
        component_class = stub_const(class_name, Class.new(described_class, &definition))
        component_class.new
      end
    end
  end
end
