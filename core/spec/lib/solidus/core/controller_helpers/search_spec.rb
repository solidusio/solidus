require 'spec_helper'

class FakesController < ApplicationController
  include Solidus::Core::ControllerHelpers::Search
end

describe Solidus::Core::ControllerHelpers::Search, type: :controller do
  controller(FakesController) {}

  describe '#build_searcher' do
    it 'returns Solidus::Core::Search::Base instance' do
      allow(controller).to receive_messages(try_solidus_current_user: create(:user),
                      current_currency: 'USD')
      expect(controller.build_searcher({}).class).to eq Solidus::Core::Search::Base
    end
  end
end
