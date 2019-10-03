# frozen_string_literal: true

require 'rails_helper'
require 'solidus/testing_support/factories/promotion_category_factory'

RSpec.describe 'promotion category factory' do
  let(:factory_class) { Solidus::PromotionCategory }

  describe 'plain promotion category' do
    let(:factory) { :promotion_category }

    it_behaves_like 'a working factory'
  end
end
