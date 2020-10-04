# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/refund_factory'

RSpec.describe 'refund factory' do
  let(:factory_class) { Spree::Refund }

  describe 'plain refund' do
    let(:factory) { :refund }

    it_behaves_like 'a working factory'
  end
end
