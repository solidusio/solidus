# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::BaseComponent, type: :component do
  describe "#spree" do
    it "gives access to spree routing helpers" do
      # The spree/core routes start as empty, so we need to add a route to test
      Spree::Core::Engine.routes.draw { get '/foo/bar', to: 'foo#bar', as: :foo_bar }

      component = described_class.new

      expect(component.spree).to respond_to(:foo_bar_path)
    ensure
      Spree::Core::Engine.routes.clear!
    end
  end

  describe "with_components" do
    it "allows overriding components" do
      component = described_class.new
      replacement_component = Class.new(described_class)
      component.with_components(foo: replacement_component)

      expect(component.component(:foo)).to eq(replacement_component)
      expect(component.component("foo")).to eq(replacement_component)
    end

    it "falls back to the original component if not overridden" do
      component = described_class.new.with_components(bar: "baz")
      default_component = Class.new(described_class)
      allow(SolidusAdmin::Container).to receive(:resolve).with("components.foo.bar.component").and_return(default_component)

      expect(component.component('foo/bar')).to eq(default_component)
    end
  end
end
