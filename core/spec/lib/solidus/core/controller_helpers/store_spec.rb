require 'spec_helper'

class FakesController < ApplicationController
  include Solidus::Core::ControllerHelpers::Store
end

describe Solidus::Core::ControllerHelpers::Store, type: :controller do
  controller(FakesController) {}

  describe '#current_store' do
    let!(:store) { create :store, default: true }
    it 'returns current store' do
      expect(controller.current_store).to eq store
    end
  end
end
