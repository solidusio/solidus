ENV['NO_FACTORIES'] = "NO FACTORIES"

require 'spec_helper'
require 'spree/testing_support/factories/state_factory'

RSpec.describe 'state factory' do
  let(:factory_class) { Spree::State }

  describe 'plain shipping rate' do
    let(:factory) { :state }

    it_behaves_like 'a working factory'
  end
end
