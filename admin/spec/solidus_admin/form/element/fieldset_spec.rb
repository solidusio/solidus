# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/form/element/fieldset"
require "solidus_admin/form/element/html"

RSpec.describe SolidusAdmin::Form::Element::Fieldset do
  include SolidusAdmin::ComponentHelpers

  describe "#call" do
    it "returns an instance of the given component" do
      component = mock_component
      element = described_class.new(component: component, elements: [])

      expect(
        element.call(double("form"), double("builder"))
      ).to be_a(component)
    end

    it "initializes the component with the given attributes" do
      component = mock_component do
        attr_reader :attributes

        def initialize(**attributes)
          @attributes = attributes
        end
      end
      attributes = { foo: :bar }
      element = described_class.new(component: component, elements: [], **attributes)

      result = element.call(double("form"), double("builder"))

      expect(result.attributes).to eq(attributes)
    end

    it "gives the concatenation of the rendered elements as the content of the component" do
      component = mock_component
      elements = [
        SolidusAdmin::Form::Element::HTML.new(html: "foo"),
        SolidusAdmin::Form::Element::HTML.new(html: "bar")
      ]
      element = described_class.new(component: component, elements: elements)
      form = SolidusAdmin::UI::Forms::Form::Component.new(elements: [element])

      # Workaround for view_context not being available in specs
      expect(form).to receive(:render_element).with(elements[0], any_args).and_return("foo")
      expect(form).to receive(:render_element).with(elements[1], any_args).and_return("bar")

      result = element.call(form, double("builder"))

      expect(result.content).to eq("foobar")
    end

    it "uses the fieldset component from the form dependencies when component is not given" do
      component = mock_component
      element = described_class.new(elements: [])
      form = SolidusAdmin::UI::Forms::Form::Component.new(
        elements: [element],
        fieldset_component: component
      )

      expect(element.call(form, double("builder"))).to be_a(component)
    end
  end
end
