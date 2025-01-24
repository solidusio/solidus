# frozen_string_literal: true

module SolidusAdmin
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
    def mock_component(class_name = "Foo::Component", &definition)
      component_class = stub_const(class_name, Class.new(described_class, &definition))
      component_class.new
    end
  end
end
