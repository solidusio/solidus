# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/working_factory"

RSpec.describe "product property factory" do
  let(:factory_class) { Spree::ProductProperty }

  describe "plain product property" do
    let(:factory) { :product_property }

    it_behaves_like "a working factory"
  end
end
