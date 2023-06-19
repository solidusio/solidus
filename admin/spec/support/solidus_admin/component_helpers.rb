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
    def mock_component(&definition)
      Class.new(SolidusAdmin::BaseComponent) do
        # ViewComponent will complain if we don't fake a class name:
        # @see https://github.com/ViewComponent/view_component/blob/5decd07842c48cbad82527daefa3fe9c65a4226a/lib/view_component/base.rb#L371
        def self.name
          "Foo"
        end
      end.tap { |klass| klass.class_eval(&definition) }
    end
  end
end
