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
end
