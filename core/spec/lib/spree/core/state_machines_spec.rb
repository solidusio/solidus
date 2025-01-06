# frozen_string_literal: true

require "rails_helper"

RSpec.describe "require 'spree/core/state_machines" do
  %w(
    inventory_unit
    order
    payment
    reimbursement
    return_authorization
    shipment
    return_item/acceptance_status
    return_item/reception_status
  ).each do |helper_name|
    describe "require 'spree/core/state_machines/#{helper_name}" do
      it "exists but will print a deprecation warning" do
        expect(Spree.deprecator).to receive(:warn).with(
          "The file \"#{Spree::Core::Engine.root}/lib/spree/core/state_machines/#{helper_name}.rb\" does not need to be `require`d any longer, it is now autoloaded.\n"
        )
        require "spree/core/state_machines/#{helper_name}"
      end
    end
  end
end
