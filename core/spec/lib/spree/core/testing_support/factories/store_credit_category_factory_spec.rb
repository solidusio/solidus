# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'store credit category factory' do
  let(:factory_class) { Spree::StoreCreditCategory }

  describe 'plain store credit category' do
    let(:factory) { :store_credit_category }

    it_behaves_like 'a working factory'
  end
end
