# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/shared_examples/working_factory"

RSpec.describe "carton factory" do
  let(:factory_class) { Spree::Carton }

  describe "plain adjustment" do
    let(:factory) { :carton }

    it_behaves_like "a working factory"
  end
end
