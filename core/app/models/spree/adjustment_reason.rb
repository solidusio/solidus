module Spree
  class AdjustmentReason < ActiveRecord::Base
    has_many :adjustments, inverse_of: :adjustment_reason

    validates :name, presence: true
    validates :name, uniqueness: {case_sensitive: false}
    validates :code, presence: true
    validates :code, uniqueness: {case_sensitive: false}

    scope :active, -> { where(active: true) }
  end
end
