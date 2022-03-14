# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'line item discount factory' do
  let(:factory_class) { Spree::LineItemDiscount }

  let(:factory) { :line_item_discount }

  it_behaves_like 'a working factory'
end
