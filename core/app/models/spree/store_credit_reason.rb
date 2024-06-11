# frozen_string_literal: true

class Spree::StoreCreditReason < Spree::Base
  scope :active, -> { where(active: true) }
  default_scope -> { order(arel_table[:name].lower) }

  validates :name, presence: true, uniqueness: { case_sensitive: false, allow_blank: true }

  has_many :store_credit_events, inverse_of: :store_credit_reason

  self.allowed_ransackable_attributes = %w[name]
end
