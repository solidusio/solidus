# frozen_string_literal: true

module Spree
  class ReturnReason < Spree::Base
    scope :active, -> { where(active: true) }
    default_scope -> { order(arel_table[:name].lower) }

    validates :name, presence: true, uniqueness: { case_sensitive: false, allow_blank: true }

    has_many :return_authorizations

    self.allowed_ransackable_attributes = %w[name]

    def self.reasons_for_return_items(return_items)
      # Only allow an inactive reason if it's already associated to a return item
      active | return_items.map(&:return_reason).compact
    end
  end
end
