# frozen_string_literal: true

require 'discard'

module Spree
  class TaxCategory < Spree::Base
    acts_as_paranoid
    include Spree::ParanoiaDeprecations

    include Discard::Model
    self.discard_column = :deleted_at

    after_discard do
      self.tax_rate_tax_categories = []
    end

    validates :name, presence: true
    validates_uniqueness_of :name, unless: :deleted_at

    has_many :tax_rate_tax_categories,
      class_name: 'Spree::TaxRateTaxCategory',
      dependent: :destroy,
      inverse_of: :tax_category
    has_many :tax_rates,
      through: :tax_rate_tax_categories,
      class_name: 'Spree::TaxRate',
      inverse_of: :tax_categories

    after_save :ensure_one_default

    def self.default
      find_by(is_default: true)
    end

    def ensure_one_default
      if is_default
        Spree::TaxCategory.where(is_default: true).where.not(id: id).update_all(is_default: false, updated_at: Time.current)
      end
    end
  end
end
