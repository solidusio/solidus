# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/working_factory"

RSpec.describe "return authorization factory" do
  let(:factory_class) { Spree::ReturnAuthorization }

  describe "plain return authorization" do
    let(:factory) { :return_authorization }

    it_behaves_like "a working factory"
  end
end
