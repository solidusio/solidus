# frozen_string_literal: true

module SolidusFriendlyPromotions
  class Promotion < Spree::Base
    belongs_to :category, optional: true
    has_many :rules
    has_many :actions
    has_many :codes
    has_many :code_batches

    validates :name, presence: true
    validates :path, uniqueness: { allow_blank: true, case_sensitive: true }
    validates :usage_limit, numericality: { greater_than: 0, allow_nil: true }
    validates :per_code_usage_limit, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :description, length: { maximum: 255 }

    self.allowed_ransackable_associations = ['codes']
    self.allowed_ransackable_attributes = %w[name path promotion_category_id]
    self.allowed_ransackable_scopes = %i[active]
  end
end
