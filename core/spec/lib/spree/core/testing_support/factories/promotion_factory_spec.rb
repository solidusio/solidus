# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/promotion_factory'

RSpec.describe 'promotion code factory' do
  let(:factory_class) { Spree::Promotion }

  describe 'plain promotion' do
    let(:factory) { :promotion }

    it_behaves_like 'a working factory'
  end

  describe 'promotion with item adjustment' do
    let(:factory) { :promotion_with_item_adjustment }

    it_behaves_like 'a working factory'
  end

  describe 'promotion with order adjustment' do
    let(:factory) { :promotion_with_order_adjustment }

    it_behaves_like 'a working factory'
  end

  describe 'promotion with item total rule' do
    let(:factory) { :promotion_with_item_total_rule }

    it_behaves_like 'a working factory'
  end
end
