# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/working_factory"

RSpec.describe "calculator factory" do
  let(:factory_class) { Spree::Calculator }

  describe "flat_rate_calculator" do
    let(:factory) { :flat_rate_calculator }

    it_behaves_like "a working factory"
  end

  describe "no amount calculator" do
    let(:factory) { :no_amount_calculator }

    it_behaves_like "a working factory"
  end

  describe "percent on item calculator" do
    let(:factory) { :percent_on_item_calculator }

    it_behaves_like "a working factory"
  end
end
