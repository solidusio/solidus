# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ControllerHelpers::Store, type: :controller do
  controller(ApplicationController) {
    include Spree::Core::ControllerHelpers::Store
  }

  describe '#current_store' do
    let!(:store) { create :store, default: true }
    it 'returns current store' do
      expect(controller.current_store).to eq store
    end
  end

  describe '#available_currencies' do
    it 'returns array of all currencies iso code' do
      expect(controller.available_currencies).to include('USD')
    end
  end

  describe '#supported_currencies' do
    it 'returns set of all currencies supported by the current store' do
      create :store, default: true, default_currency: 'USD', currencies: Set['EUR']

      expect(controller.supported_currencies).to eq(Set['USD', 'EUR'])
    end
  end

  describe '#multicurrency?' do
    it 'returns whether current store is multicurrency' do
      create :store, default: true, default_currency: 'USD', currencies: Set['EUR']

      expect(controller.multicurrency?).to be(true)
    end
  end
end
