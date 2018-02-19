# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/country_factory'

RSpec.describe 'country factory' do
  let(:factory_class) { Spree::Country }

  describe 'plain adjustment' do
    let(:factory) { :country }

    it_behaves_like 'a working factory'
  end
end
