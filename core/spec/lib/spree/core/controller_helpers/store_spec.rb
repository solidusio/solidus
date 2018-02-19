# frozen_string_literal: true

require 'rails_helper'

class FakesController < ApplicationController
  include Spree::Core::ControllerHelpers::Store
end

RSpec.describe Spree::Core::ControllerHelpers::Store, type: :controller do
  controller(FakesController) {}

  describe '#current_store' do
    let!(:store) { create :store, default: true }
    it 'returns current store' do
      expect(controller.current_store).to eq store
    end
  end
end
