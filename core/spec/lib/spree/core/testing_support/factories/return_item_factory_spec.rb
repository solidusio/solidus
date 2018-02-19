# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/return_item_factory'

RSpec.describe 'return item factory' do
  let(:factory_class) { Spree::ReturnItem }

  describe 'plain return item' do
    let(:factory) { :return_item }

    it_behaves_like 'a working factory'
  end

  describe 'exchange return item' do
    let(:factory) { :exchange_return_item }

    it_behaves_like 'a working factory'
  end
end
