# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shipment factory' do
  let(:factory_class) { Spree::Shipment }

  describe 'plain shipment' do
    let(:factory) { :shipment }

    it_behaves_like 'a working factory'
  end
end
