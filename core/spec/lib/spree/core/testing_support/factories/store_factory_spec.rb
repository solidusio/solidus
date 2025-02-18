# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/working_factory"

RSpec.describe "store factory" do
  let(:factory_class) { Spree::Store }

  describe "store" do
    let(:factory) { :store }

    it_behaves_like "a working factory"
  end
end
