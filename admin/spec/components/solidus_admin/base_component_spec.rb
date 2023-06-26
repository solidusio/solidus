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
end
