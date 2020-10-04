# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

require_dependency 'spree/calculator'

module Spree
  RSpec.describe Calculator::PercentPerItem, type: :model do
    it_behaves_like 'a calculator with a description'
  end
end
