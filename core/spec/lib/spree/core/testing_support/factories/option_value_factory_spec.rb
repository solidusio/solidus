# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/option_value_factory'

RSpec.describe 'option value factory' do
  let(:factory_class) { Spree::OptionValue }

  describe 'plain option value' do
    let(:factory) { :option_value }

    it_behaves_like 'a working factory'
  end
end
