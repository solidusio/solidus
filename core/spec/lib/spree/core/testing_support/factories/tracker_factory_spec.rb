require 'spec_helper'
require 'spree/testing_support/factories/tracker_factory'

RSpec.describe 'tracker factory' do
  let(:factory_class) { Spree::Tracker }

  describe 'tracker' do
    let(:factory) { :tracker }

    it_behaves_like 'a working factory'
  end
end
