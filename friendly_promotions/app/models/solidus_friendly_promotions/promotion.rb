# frozen_string_literal: true

module SolidusFriendlyPromotions
  class Promotion < Spree::Base
    belongs_to :category, optional: true
    validates :name, presence: true
    validates :path, uniqueness: { allow_blank: true, case_sensitive: true }
    validates :usage_limit, numericality: { greater_than: 0, allow_nil: true }
    validates :per_code_usage_limit, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :description, length: { maximum: 255 }
  end
end
