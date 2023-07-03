# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::BaseComponent, type: :component do
  describe "#spree" do
    it "gives access to spree routing helpers" do
      # The spree/core routes start as empty, so we need to add a route to test
      Spree::Core::Engine.routes.draw { get '/foo/bar', to: 'foo#bar', as: :foo_bar }

      component = described_class.new

      expect(component.spree.foo_bar_path).to eq("/foo/bar")
    ensure
      Spree::Core::Engine.routes.clear!
    end
  end

  describe "#solidus_admin" do
    it "gives access to solidus_admin routing helpers" do
      allow(SolidusAdmin::Engine.routes.url_helpers).to receive(:foo_path).and_return("/foo/bar")
      component = described_class.new

      expect(component.solidus_admin.foo_path).to eq("/foo/bar")
    end
  end

  describe "#solidus_admin_with_fallbacks" do
    it "gives access to solidus_admin routing helpers with fallbacks to spree ones" do
      allow(SolidusAdmin::Engine.routes.url_helpers).to receive(:foo_path).and_return("/foo")
      allow(Spree::Core::Engine.routes.url_helpers).to receive(:admin_bar_path).and_return("/bar")

      component = described_class.new

      aggregate_failures do
        expect(component.solidus_admin_with_fallbacks.foo_path).to eq("/foo")
        expect(component.solidus_admin_with_fallbacks.bar_path).to eq("/bar")
      end
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
