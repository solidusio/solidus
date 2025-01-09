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
end
