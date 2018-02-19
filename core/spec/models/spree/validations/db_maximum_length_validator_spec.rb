# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Validations::DbMaximumLengthValidator, type: :model do
  with_model 'LimitedProduct', scope: :all do
    table do |t|
      t.string :slug, limit: 255
    end

    model do
      validates_with Spree::Validations::DbMaximumLengthValidator, field: :slug
    end
  end

  let(:record) { LimitedProduct.new(slug: slug) }

  context "when slug is below limit" do
    let(:slug) { 'a' * 255 }
    it 'should be valid' do
      expect(record).to be_valid
      expect(record.errors).to be_empty
    end
  end

  context "when slug is too long" do
    let(:slug) { 'a' * 256 }
    it 'should be invalid and set error' do
      expect(record).not_to be_valid
      expect(record.errors[:slug]).to include(I18n.t("errors.messages.too_long", count: 255))
    end
  end
end
