require 'spec_helper'

describe Solidus::Validations::DbMaximumLengthValidator, type: :model do
  context 'when Solidus::Product' do
    Solidus::Product.class_eval do
      attribute :slug, ActiveRecord::Type::String.new(limit: 255)
      # Slug currently has no validation for maximum length
      validates_with Solidus::Validations::DbMaximumLengthValidator, field: :slug
    end
    let(:limit) { 255 }
    let(:product) { Solidus::Product.new }
    let(:slug) { "x" * (limit + 1)}

    before do
      product.slug = slug
    end

    it 'should maximum validate slug' do
      product.valid?
      expect(product.errors[:slug]).to include(I18n.t("errors.messages.too_long", count: limit))
    end
  end
end
