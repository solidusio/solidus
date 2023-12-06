# frozen_string_literal: true

module Spree
  class RefundReason < Spree::Base
    scope :active, -> { where(active: true) }
    default_scope -> { order(arel_table[:name].lower) }

    validates :name, presence: true, uniqueness: { case_sensitive: false, allow_blank: true }

    RETURN_PROCESSING_REASON = 'Return processing'

    has_many :refunds

    def self.return_processing_reason
      find_by!(name: RETURN_PROCESSING_REASON, mutable: false)
    end
  end
end
