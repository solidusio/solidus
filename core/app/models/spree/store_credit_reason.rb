# frozen_string_literal: true

class Spree::StoreCreditReason < Spree::Base
  include Spree::NamedType

  has_many :store_credits, inverse_of: :store_credit_reason

  validates :name, presence: true, uniqueness: { case_sensitive: false, allow_blank: true }

  scope :active, -> { where(active: true) }
end
