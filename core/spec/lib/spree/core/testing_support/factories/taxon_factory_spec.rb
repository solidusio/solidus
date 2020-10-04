# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/taxon_factory'

RSpec.describe 'taxon factory' do
  let(:factory_class) { Spree::Taxon }

  describe 'taxon' do
    let(:factory) { :taxon }

    it_behaves_like 'a working factory'
  end
end
