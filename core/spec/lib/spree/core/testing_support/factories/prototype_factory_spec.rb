require 'spec_helper'
require 'spree/testing_support/factories/prototype_factory'

RSpec.describe 'prototype factory' do
  let(:factory_class) { Spree::Prototype }

  describe 'plain prototype' do
    let(:factory) { :prototype }

    it_behaves_like 'a working factory'
  end
end
