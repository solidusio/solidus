# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::StoreCreditPrioritizer, type: :model do
  let(:order) { create(:order) }
  let(:credits) { Spree::StoreCredit.all }
  let(:sorter) { described_class.new(credits, order) }

  describe "#call" do
    subject { sorter.call }

    let(:credit_type_1) { create(:primary_credit_type, priority: "30") }
    let!(:credit_1) { create(:store_credit, credit_type: credit_type_1) }
    let(:credit_type_2) { create(:primary_credit_type, priority: "20") }
    let!(:credit_2) { create(:store_credit, credit_type: credit_type_2) }
    let(:credit_type_3) { create(:primary_credit_type, priority: "10") }
    let!(:credit_3) { create(:store_credit, credit_type: credit_type_3) }

    it "returns the credits ordered by their priority" do
      expect(subject.to_a).to eq([credit_3, credit_2, credit_1])
    end
  end
end
