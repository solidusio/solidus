# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::UI::Forms::Guidance::Component, type: :component do
  describe "#initialize" do
    it "uses given errors when form is bound to a model" do
      form = double("form", object: double("model", errors: {}))

      component = described_class.new(builder: form, field: :name, hint: nil, errors: { name: ["can't be blank"] })

      expect(component.errors?).to be(true)
    end

    it "uses model errors when form is bound to a model and they are not given" do
      form = double("form", object: double("model", errors: { name: ["can't be blank"] }))

      component = described_class.new(builder: form, field: :name, hint: nil, errors: nil)

      expect(component.errors?).to be(true)
    end

    it "uses given errors when form is not bound to a model" do
      form = double("form", object: nil)

      component = described_class.new(builder: form, field: :name, hint: nil, errors: { name: ["can't be blank"] })

      expect(component.errors?).to be(true)
    end

    it "raises an error when form is not bound to a model and errors are not given" do
      form = double("form", object: nil)

      expect { described_class.new(builder: form, field: :name, errors: nil) }.to raise_error(ArgumentError)
    end
  end
end
