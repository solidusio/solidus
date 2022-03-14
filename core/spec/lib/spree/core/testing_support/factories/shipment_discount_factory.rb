# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shipment discount factory' do
  let(:factory_class) { Spree::ShipmentDiscount }

  let(:factory) { :shipment_discount }

  it_behaves_like 'a working factory'
end
