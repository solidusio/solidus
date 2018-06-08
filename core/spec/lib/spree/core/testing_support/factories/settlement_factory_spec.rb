# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/settlement_factory'

RSpec.describe 'settlement factory' do
  let(:factory_class) { Spree::Settlement }

  describe 'plain settlement' do
    let(:factory) { :settlement }

    it_behaves_like 'a working factory'
  end
end
