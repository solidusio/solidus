# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

RSpec.describe Spree::Calculator::FreeShipping, type: :model do
  it_behaves_like 'a calculator with a description'
end
