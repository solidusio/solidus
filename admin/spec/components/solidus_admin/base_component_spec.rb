# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::BaseComponent, type: :component do
  describe "#icon_tag" do
    it "renders a remixicon svg" do
      component = mock_component do
        def call
          icon_tag("user-line")
        end
      end.new

      render_inline(component)

      svg = page.find("svg use")["xlink:href"]
      expect(svg).to match(/#ri-user-line/)
    end
  end

  describe "#spree" do
    it "gives access to spree routing helpers" do
      expect(described_class.new).to respond_to(:spree)
    end
  end

  describe "#solidus_admin" do
    it "gives access to solidus_admin routing helpers" do
      expect(described_class.new).to respond_to(:solidus_admin)
    end
  end

  describe "#main_app" do
    it "gives access to main_app routing helpers" do
      expect(described_class.new).to respond_to(:main_app)
    end
  end

  describe ".stimulus_id" do
    it "returns the stimulus id for the component" do
      stub_const("SolidusAdmin::Foo::Bar::Component", Class.new(described_class))

      expect(SolidusAdmin::Foo::Bar::Component.stimulus_id).to eq("foo--bar")
      expect(SolidusAdmin::Foo::Bar::Component.new.stimulus_id).to eq("foo--bar")
    end
  end

  describe "missing translations" do
    it "logs and shows the full chain of keys" do
      debug_logs = []

      allow(Rails.logger).to receive(:debug) { debug_logs << _1 }

      component_class = stub_const("Foo::Component", Class.new(described_class){ erb_template "" })
      component = component_class.new
      render_inline(component)
      translation = component.translate("foo.bar.baz")

      expect(translation).to eq("translation missing: en.foo.bar.baz")
      expect(debug_logs).to include(%{  [Foo::Component] Missing translation: en.foo.bar.baz})
    end
  end
end
