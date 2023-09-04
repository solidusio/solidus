# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/form/element/field"

RSpec.describe SolidusAdmin::Form::Element::Field do
  include SolidusAdmin::ComponentHelpers

  describe "#call" do
    it "returns an instance of the given component" do
      component = mock_component do
        def initialize(builder:); end
      end
      builder = double("builder")

      element = described_class.new(component: component)

      expect(
        element.call(double("form"), builder)
      ).to be_a(component)
    end

    it "initializes the component with the given attributes" do
      component = mock_component do
        attr_reader :builder, :attributes

        def initialize(builder:, **attributes)
          @builder = builder
          @attributes = attributes
        end
      end
      attributes = { foo: :bar }
      element = described_class.new(component: component, **attributes)

      result = element.call(double("form"), double("builder"))

      expect(result.attributes).to eq(attributes)
    end

    it "initializes the component with the given builder" do
      component = mock_component do
        attr_reader :builder

        def initialize(builder:)
          @builder = builder
        end
      end
      builder = double("builder")
      element = described_class.new(component: component)

      result = element.call(double("form"), builder)

      expect(result.builder).to be(builder)
    end

    it "infers the component class from the form dependencies when given as a Symbol" do
      text_field_component_class = mock_component do
        def initialize(builder:); end
      end
      element = described_class.new(component: :text_field)
      component = SolidusAdmin::UI::Forms::Form::Component.new(elements: [element])

      allow(component).to receive(:component).and_call_original
      allow(component).to receive(:component).with('ui/forms/text_field').and_return(text_field_component_class)

      result = element.call(component, double("builder"))

      expect(result).to be_a(text_field_component_class)
    end
  end
end
