# frozen_string_literal: true

require 'rails_helper'

class FakesController < ApplicationController
  include Spree::Core::ControllerHelpers::Search
end

RSpec.describe Spree::Core::ControllerHelpers::Search, type: :controller do
  controller(FakesController) {}

  describe '#build_searcher' do
    it 'returns Spree::Core::Search::Base instance' do
      allow(controller).to receive_messages(
        try_spree_current_user: create(:user),
        current_pricing_options: Spree::Config.pricing_options_class.new(currency: 'USD')
      )
      expect(controller.build_searcher({}).class).to eq Spree::Core::Search::Base
    end
  end
end
