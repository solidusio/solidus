# frozen_string_literal: true

require "rails_helper"

# RESOURCE FIXTURE
CreateLimitedProducts = Class.new(ActiveRecord::Migration[5.1]) do
  def change
    create_table(:limited_products) do |t|
      t.string :slug, limit: 255
    end
  end
end

LimitedProduct = Class.new(ActiveRecord::Base) do
  validates_with Spree::Validations::DbMaximumLengthValidator, field: :slug
end

RSpec.describe Spree::Validations::DbMaximumLengthValidator, type: :model do
  before(:all) do
    CreateLimitedProducts.migrate(:up)
  end

  # TEAR DOWN RESOURCE FIXTURE
  after(:all) do
    # Database
    CreateLimitedProducts.migrate(:down)
    Object.send(:remove_const, :CreateLimitedProducts)

    # Model
    Object.send(:remove_const, :LimitedProduct)
  end

  let(:record) { LimitedProduct.new(slug:) }

  context "when slug is below limit" do
    let(:slug) { "a" * 255 }
    it "should be valid" do
      expect(record).to be_valid
      expect(record.errors).to be_empty
    end
  end

  context "when slug is too long" do
    let(:slug) { "a" * 256 }
    it "should be invalid and set error" do
      expect(record).not_to be_valid
      expect(record.errors[:slug]).to include(I18n.t("errors.messages.too_long", count: 255))
    end
  end
end
