# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/promotion_code_factory'

RSpec.describe 'promotion code factory' do
  let(:factory_class) { Spree::PromotionCode }

  describe 'plain promotion code' do
    let(:factory) { :promotion_code }

    it_behaves_like 'a working factory'
  end
end
