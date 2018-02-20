# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::StoreCreditCategory, type: :model do
  describe "#non_expiring?" do
    let(:store_credit_category) { build(:store_credit_category, name: category_name) }

    context "non-expiring type store credit" do
      let(:category_name) { "Non-expiring" }
      it { expect(store_credit_category).to be_non_expiring }
    end

    context "expiring type store credit" do
      let(:category_name) { "Expiring" }
      it { expect(store_credit_category).not_to be_non_expiring }
    end
  end
end
