# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'promotion category factory' do
  let(:factory_class) { Spree::PromotionCategory }

  describe 'plain promotion category' do
    let(:factory) { :promotion_category }

    it_behaves_like 'a working factory'
  end
end
