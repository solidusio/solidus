# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/option_type_factory'

RSpec.describe 'option type factory' do
  let(:factory_class) { Solidus::OptionType }

  describe 'plain option type' do
    let(:factory) { :option_type }

    it_behaves_like 'a working factory'
  end
end
