# frozen_string_literal: true

require "rails_helper"

RSpec.describe "require 'spree/core/controller_helpers" do
  %w(
    auth
    common
    order
    payment_parameters
    pricing
    search
    store
    strong_parameters
  ).each do |helper_name|
    describe "require 'spree/core/controller_helpers/#{helper_name}" do
      it "exists but will print a deprecation warning" do
        expect(Spree.deprecator).to receive(:warn).with(
          "The file \"#{Spree::Core::Engine.root}/lib/spree/core/controller_helpers/#{helper_name}.rb\" does not need to be `require`d any longer, it is now autoloaded.\n"
        )
        require "spree/core/controller_helpers/#{helper_name}"
      end
    end
  end
end
