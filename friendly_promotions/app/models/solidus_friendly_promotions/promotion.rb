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

    scope :active, -> { has_actions.started_and_unexpired }
    scope :started_and_unexpired, -> do
      table = arel_table
      time = Time.current

      where(table[:starts_at].eq(nil).or(table[:starts_at].lt(time))).
        where(table[:expires_at].eq(nil).or(table[:expires_at].gt(time)))
    end
    scope :has_actions, -> do
      joins(:actions).distinct
    end

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

    # Whether the promotion has exceeded its usage restrictions.
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage limit
    # @return true or false
    def usage_limit_exceeded?(excluded_orders: [])
      if usage_limit
        usage_count(excluded_orders: excluded_orders) >= usage_limit
      end
    end
  end
end
