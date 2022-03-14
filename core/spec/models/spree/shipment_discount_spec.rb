# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::ShipmentDiscount do
  subject(:shipment_discount) { build(:shipment_discount) }

  it { is_expected.to respond_to(:shipment) }
  it { is_expected.to respond_to(:promotion_action) }
  it { is_expected.to respond_to(:amount) }
  it { is_expected.to respond_to(:label) }
end
