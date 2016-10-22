require 'spec_helper'
require 'shared_examples/calculator_shared_examples'

describe Spree::Calculator::FreeShipping, type: :model do
  it_behaves_like 'a calculator with a description'
end
