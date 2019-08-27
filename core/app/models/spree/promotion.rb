# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    MATCH_POLICIES = %w(all any)
    UNACTIVATABLE_ORDER_STATES = ["complete", "awaiting_return", "returned"]

    attr_reader :eligibility_errors

    belongs_to :promotion_category, optional: true

    has_many :promotion_rules, autosave: true, dependent: :destroy, inverse_of: :promotion
    alias_method :rules, :promotion_rules

    has_many :promotion_actions, autosave: true, dependent: :destroy, inverse_of: :promotion
    alias_method :actions, :promotion_actions

    has_many :order_promotions, class_name: "Spree::OrderPromotion"
    has_many :orders, through: :order_promotions

    has_many :codes, class_name: "Spree::PromotionCode", inverse_of: :promotion, dependent: :destroy
    alias_method :promotion_codes, :codes

    has_many :promotion_code_batches, class_name: "Spree::PromotionCodeBatch", dependent: :destroy

    accepts_nested_attributes_for :promotion_actions, :promotion_rules

    validates_associated :rules

    validates :name, presence: true
    validates :path, uniqueness: { allow_blank: true }
    validates :usage_limit, numericality: { greater_than: 0, allow_nil: true }
    validates :per_code_usage_limit, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :description, length: { maximum: 255 }
    validate :apply_automatically_disallowed_with_codes_or_paths

    before_save :normalize_blank_values

    scope :coupons, -> { joins(:codes).distinct }
    scope :advertised, -> { where(advertise: true) }
    scope :active, -> do
      table = arel_table
      time = Time.current
      where(table[:starts_at].eq(nil).or(table[:starts_at].lt(time))).
        where(table[:expires_at].eq(nil).or(table[:expires_at].gt(time)))
    end
    scope :applied, -> { joins(:order_promotions).distinct }

    self.whitelisted_ransackable_associations = ['codes']
    self.whitelisted_ransackable_attributes = %w[name path promotion_category_id]

    def self.order_activatable?(order)
      order && !UNACTIVATABLE_ORDER_STATES.include?(order.state)
    end

    def self.with_coupon_code(val)
      joins(:codes).where(
        PromotionCode.arel_table[:value].eq(val.downcase)
      ).first
    end

    def as_json(options = {})
      options[:except] ||= :code
      super
    end

    def not_started?
      !started?
    end

    def started?
      starts_at.nil? || starts_at < Time.current
    end

    def expired?
      expires_at.present? && expires_at < Time.current
    end

    def not_expired?
      !expired?
    end

    def active?
      started? && not_expired?
    end

    def inactive?
      !active?
    end

    def activate(order:, line_item: nil, user: nil, path: nil, promotion_code: nil)
      return unless self.class.order_activatable?(order)

      payload = {
        order: order,
        promotion: self,
        line_item: line_item,
        user: user,
        path: path,
        promotion_code: promotion_code
      }

      # Track results from actions to see if any action has been taken.
      # Actions should return nil/false if no action has been taken.
      # If an action returns true, then an action has been taken.
      results = actions.map do |action|
        action.perform(payload)
      end
      # If an action has been taken, report back to whatever activated this promotion.
      action_taken = results.include?(true)

      if action_taken
        # connect to the order
        order.order_promotions.find_or_create_by!(
          promotion: self,
          promotion_code: promotion_code,
        )
        order.promotions.reset
        order_promotions.reset
        orders.reset
      end

      action_taken
    end

    # called anytime order.recalculate happens
    def eligible?(promotable, promotion_code: nil)
      return false if inactive?
      return false if blacklisted?(promotable)

      excluded_orders = eligibility_excluded_orders(promotable)
      return false if usage_limit_exceeded?(excluded_orders: excluded_orders)
      return false if promotion_code&.usage_limit_exceeded?(excluded_orders: excluded_orders)

      !!eligible_rules(promotable, {})
    end

    # eligible_rules returns an array of promotion rules where eligible? is true for the promotable
    # if there are no such rules, an empty array is returned
    # if the rules make this promotable ineligible, then nil is returned (i.e. this promotable is not eligible)
    def eligible_rules(promotable, options = {})
      # Promotions without rules are eligible by default.
      return [] if rules.none?

      eligible = lambda { |rule| rule.eligible?(promotable, options) }
      specific_rules = rules.for(promotable)
      return [] if specific_rules.none?

      if match_all?
        # If there are rules for this promotion, but no rules for this
        # particular promotable, then the promotion is ineligible by default.
        unless specific_rules.all?(&eligible)
          @eligibility_errors = specific_rules.map(&:eligibility_errors).detect(&:present?)
          return nil
        end
        specific_rules
      else
        unless specific_rules.any?(&eligible)
          @eligibility_errors = specific_rules.map(&:eligibility_errors).detect(&:present?)
          return nil
        end
        specific_rules.select(&eligible)
      end
    end

    def products
      rules.where(type: "Spree::Promotion::Rules::Product").map(&:products).flatten.uniq
    end

    # Whether the promotion has exceeded it's usage restrictions.
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage limit
    # @return true or false
    def usage_limit_exceeded?(excluded_orders: [])
      if usage_limit
        usage_count(excluded_orders: excluded_orders) >= usage_limit
      end
    end

    # Number of times the code has been used overall
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage count
    # @return [Integer] usage count
    def usage_count(excluded_orders: [])
      Spree::Adjustment.promotion.
        eligible.
        in_completed_orders(excluded_orders: excluded_orders).
        where(source_id: actions).
        count(:order_id)
    end

    def line_item_actionable?(order, line_item, promotion_code: nil)
      return false if blacklisted?(line_item)

      if eligible?(order, promotion_code: promotion_code)
        rules = eligible_rules(order)
        if rules.blank?
          true
        else
          rules.send(match_all? ? :all? : :any?) do |rule|
            rule.actionable? line_item
          end
        end
      else
        false
      end
    end

    def used_by?(user, excluded_orders = [])
      [
        :adjustments,
        :line_item_adjustments,
        :shipment_adjustments
      ].any? do |adjustment_type|
        user.orders.complete.joins(adjustment_type).where(
          spree_adjustments: {
            source_type: "Spree::PromotionAction",
            source_id: actions.map(&:id),
            eligible: true
          }
        ).where.not(
          id: excluded_orders.map(&:id)
        ).any?
      end
    end

    # Removes a promotion and any adjustments or other side effects from an
    # order.
    # @param order [Spree::Order] the order to remove the promotion from.
    # @return [void]
    def remove_from(order)
      actions.each do |action|
        action.remove_from(order)
      end
      # note: this destroys the join table entry, not the promotion itself
      order.promotions.destroy(self)
      order.order_promotions.reset
      order_promotions.reset
    end

    private

    def blacklisted?(promotable)
      case promotable
      when Spree::LineItem
        !promotable.product.promotionable?
      when Spree::Order
        promotable.line_items.joins(:product).where(spree_products: { promotionable: false }).exists?
      end
    end

    def normalize_blank_values
      self[:path] = nil if self[:path].blank?
    end

    def match_all?
      match_policy == "all"
    end

    def apply_automatically_disallowed_with_codes_or_paths
      return unless apply_automatically

      errors.add(:apply_automatically, :disallowed_with_code) if codes.any?
      errors.add(:apply_automatically, :disallowed_with_path) if path.present?
    end

    def eligibility_excluded_orders(promotable)
      if promotable.is_a?(Spree::Order)
        [promotable]
      elsif promotable.respond_to?(:order)
        [promotable.order]
      else
        []
      end
    end
  end
end
