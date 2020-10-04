# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/reimbursement_type_factory'

RSpec.describe 'reimbursement type factory' do
  let(:factory_class) { Spree::ReimbursementType }

  describe 'plain reimbursement type' do
    let(:factory) { :reimbursement_type }

    it_behaves_like 'a working factory'
  end
end
