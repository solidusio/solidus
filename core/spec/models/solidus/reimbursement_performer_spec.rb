# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::ReimbursementPerformer, type: :model do
  let(:reimbursement)           { create(:reimbursement, return_items_count: 1) }
  let(:return_item)             { reimbursement.return_items.first }
  let(:reimbursement_type)      { double("ReimbursementType") }
  let(:reimbursement_type_hash) { { reimbursement_type => [return_item] } }
  let(:created_by_user) { create(:user, email: 'user@email.com') }

  before do
    expect(Solidus::ReimbursementPerformer).to receive(:calculate_reimbursement_types).and_return(reimbursement_type_hash)
  end

  describe ".simulate" do
    subject { Solidus::ReimbursementPerformer.simulate(reimbursement, created_by: created_by_user) }

    it "reimburses each calculated reimbursement types with the correct return items as a simulation" do
      expect(reimbursement_type).to receive(:reimburse).with(reimbursement, [return_item], true, created_by: created_by_user)
      subject
    end
  end

  describe '.perform' do
    subject { Solidus::ReimbursementPerformer.perform(reimbursement, created_by: created_by_user) }

    it "reimburses each calculated reimbursement types with the correct return items as a simulation" do
      expect(reimbursement_type).to receive(:reimburse).with(reimbursement, [return_item], false, created_by: created_by_user)
      subject
    end
  end
end
