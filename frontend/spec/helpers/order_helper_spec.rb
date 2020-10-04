# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Spree::OrdersHelper, type: :helper do
    # Regression test for https://github.com/spree/spree/issues/2518 and https://github.com/spree/spree/issues/2323
    it "truncates HTML correctly in product description" do
      product = double(description: "<strong>" + ("a" * 95) + "</strong> This content is invisible.")
      expected = "<strong>" + ("a" * 95) + "</strong>..."
      expect(truncated_product_description(product)).to eq(expected)
    end
  end
end
