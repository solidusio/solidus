# frozen_string_literal: true

module SolidusFriendlyPromotions
  class Promotion < Spree::Base
    belongs_to :category, class_name: "SolidusFriendlyPromotions::PromotionCategory", foreign_key: :promotion_category_id, optional: true
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


    # All orders that have been discounted using this promotion
    def discounted_orders
      Spree::Order.
        joins(:all_adjustments).
        where(
          spree_adjustments: {
            source_type: "SolidusFriendlyPromotions::Action",
            source_id: actions.map(&:id),
            eligible: true
          }
        ).distinct
    end

    # Number of times the code has been used overall
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage count
    # @return [Integer] usage count
    def usage_count(excluded_orders: [])
      discounted_orders.
        complete.
        where.not(id: [excluded_orders.map(&:id)]).
        where.not(spree_orders: { state: :canceled }).
        count
    end
  end
end
