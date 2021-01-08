# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'order promotion factory' do
  let(:factory_class) { Spree::OrderPromotion }

  describe 'plain order promotion' do
    let(:factory) { :order_promotion }

    it_behaves_like 'a working factory'
  end
end
