require 'spec_helper'
require 'spree/testing_support/factories/store_credit_update_reason_factory'

RSpec.describe 'store credit update reason factory' do
  let(:factory_class) { Spree::StoreCreditUpdateReason }

  describe 'store credit update reason' do
    let(:factory) { :store_credit_update_reason }

    it_behaves_like 'a working factory'
  end
end
