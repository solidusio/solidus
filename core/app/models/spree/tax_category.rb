module Spree
  class TaxCategory < Spree::Base
    acts_as_paranoid
    validates :name, presence: true
    validates_uniqueness_of :name, unless: :deleted_at

    has_many :tax_rates, dependent: :destroy, inverse_of: :tax_category
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
