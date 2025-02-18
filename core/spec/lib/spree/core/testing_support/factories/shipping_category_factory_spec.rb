# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/working_factory"

RSpec.describe "shipping category factory" do
  let(:factory_class) { Spree::ShippingCategory }

  describe "plain shipping category" do
    let(:factory) { :shipping_category }

    it_behaves_like "a working factory"
  end
end
