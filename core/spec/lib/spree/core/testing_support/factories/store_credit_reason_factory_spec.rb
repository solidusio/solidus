# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/working_factory"

RSpec.describe "store credit reason factory" do
  let(:factory_class) { Spree::StoreCreditReason }

  describe "store credit reason" do
    let(:factory) { :store_credit_reason }

    it_behaves_like "a working factory"
  end
end
