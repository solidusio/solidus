# frozen_string_literal: true

require 'rails_helper'
require 'spree/core/product_filters'

RSpec.describe Spree::Core::Search::Base do
  it 'shows a deprecation warning when initialized' do
    expect(Spree::Deprecation).to receive(:warn).with(/This class will be moving the to solidus_frontend gem/)

    params = { per_page: "" }
    searcher = Spree::Core::Search::Base.new(params)
  end
end
