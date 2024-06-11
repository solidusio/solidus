# frozen_string_literal: true

module Spree
  class ReimbursementType < Spree::Base
    scope :active, -> { where(active: true) }
    default_scope -> { order(arel_table[:name].lower) }

    validates :name, presence: true, uniqueness: { case_sensitive: false, allow_blank: true }

    ORIGINAL = 'original'

    has_many :return_items

    self.allowed_ransackable_attributes = %w[name]

    # This method will reimburse the return items based on however it child implements it
    # By default it takes a reimbursement, the return items it needs to reimburse, and if
    # it is a simulation or a real reimbursement. This should return an array
    def self.reimburse(_reimbursement, _return_items, _simulate, *_optional_args)
      raise "Implement me"
    end
  end
end
