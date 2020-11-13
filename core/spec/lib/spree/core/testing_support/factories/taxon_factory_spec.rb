# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'taxon factory' do
  let(:factory_class) { Spree::Taxon }

  describe 'taxon' do
    let(:factory) { :taxon }

    it_behaves_like 'a working factory'
  end
end
