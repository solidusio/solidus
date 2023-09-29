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
      without_partial_double_verification do
        allow(Spree::Core::Engine.routes.url_helpers).to receive(:foo_path).and_return("/foo/bar")
      end
      component = described_class.new

      expect(component.spree.foo_path).to eq("/foo/bar")
    end
  end

  describe "#solidus_admin" do
    it "gives access to solidus_admin routing helpers" do
      without_partial_double_verification do
        allow(SolidusAdmin::Engine.routes.url_helpers).to receive(:foo_path).and_return("/foo/bar")
      end
      component = described_class.new

      expect(component.solidus_admin.foo_path).to eq("/foo/bar")
    end
  end

  describe ".stimulus_id" do
    it "returns the stimulus id for the component" do
      stub_const("SolidusAdmin::Foo::Bar::Component", Class.new(described_class))

      expect(SolidusAdmin::Foo::Bar::Component.stimulus_id).to eq("foo--bar")
      expect(SolidusAdmin::Foo::Bar::Component.new.stimulus_id).to eq("foo--bar")
    end
  end
end
