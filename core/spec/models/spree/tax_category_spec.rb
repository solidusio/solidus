# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::TaxCategory, type: :model do
  context 'default tax category' do
    let(:tax_category) { create(:tax_category) }
    let(:new_tax_category) { create(:tax_category) }

    before do
      tax_category.update_column(:is_default, true)
    end

    it "should undefault the previous default tax category" do
      new_tax_category.update({ is_default: true })
      expect(new_tax_category.is_default).to be true

      tax_category.reload
      expect(tax_category.is_default).to be false
    end

    it "should undefault the previous default tax category except when updating the existing default tax category" do
      tax_category.update_column(:description, "Updated description")

      tax_category.reload
      expect(tax_category.is_default).to be true
    end
  end

  context ".discard" do
    let(:tax_category) { create(:tax_category) }

    it "set deleted_at correctly" do
      tax_category.discard
      expect(tax_category.deleted_at).not_to be_blank
    end

    context "when there are tax_rates associated" do
      let(:tax_rate) { create(:tax_rate) }
      let(:tax_category) { tax_rate.tax_categories.first }

      it 'correctly discard association records' do
        expect { tax_category.discard }
          .to change { tax_category.tax_rates.size }
          .from(1)
          .to(0)
      end
    end
  end
end
