# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    UNACTIVATABLE_ORDER_STATES = ["complete", "awaiting_return", "returned"]

    include Spree::PromotionUsageClaims

    attr_reader :eligibility_errors

    belongs_to :promotion_category, optional: true

    has_many :promotion_rules, autosave: true, dependent: :destroy, inverse_of: :promotion
    alias_method :rules, :promotion_rules

    has_many :promotion_actions, autosave: true, dependent: :destroy, inverse_of: :promotion
    alias_method :actions, :promotion_actions

    has_many :order_promotions, class_name: "Spree::OrderPromotion", inverse_of: :promotion, dependent: :destroy
    has_many :orders, through: :order_promotions

    has_many :codes, class_name: "Spree::PromotionCode", inverse_of: :promotion, dependent: :destroy
    alias_method :promotion_codes, :codes

    has_many :promotion_code_batches, class_name: "Spree::PromotionCodeBatch", dependent: :destroy

    accepts_nested_attributes_for :promotion_actions, :promotion_rules

    validates_associated :rules

    validates :name, presence: true
    validates :path, uniqueness: {allow_blank: true, case_sensitive: true}
    validates :usage_limit, numericality: {greater_than: 0, allow_nil: true}
    validates :per_code_usage_limit, numericality: {greater_than_or_equal_to: 0, allow_nil: true}
    validates :description, length: {maximum: 255}
    validate :apply_automatically_disallowed_with_paths

    before_save :normalize_blank_values
    after_save :recalculate_usage_claims_counts,
      if: -> { saved_change_to_usage_limit?(from: nil) || saved_change_to_per_code_usage_limit?(from: nil) }

    scope :coupons, -> { joins(:codes).distinct }
    scope :advertised, -> { where(advertise: true) }
    scope :active, -> { has_actions.started_and_unexpired }
    scope :started_and_unexpired, -> do
      table = arel_table
      time = Time.current

      where(table[:starts_at].eq(nil).or(table[:starts_at].lt(time)))
        .where(table[:expires_at].eq(nil).or(table[:expires_at].gt(time)))
    end
    scope :has_actions, -> do
      joins(:promotion_actions).distinct
    end
    scope :applied, -> { joins(:order_promotions).distinct }

    self.allowed_ransackable_associations = ["codes"]
    self.allowed_ransackable_attributes = %w[name path promotion_category_id]
    self.allowed_ransackable_scopes = %i[active]

    def self.order_activatable?(order)
      order && !UNACTIVATABLE_ORDER_STATES.include?(order.state)
    end

    def self.with_coupon_code(val)
      joins(:codes).where(
        PromotionCode.arel_table[:value].eq(val.downcase)
      ).first
    end

    # All orders that have been discounted using this promotion
    def discounted_orders
      Spree::Order
        .joins(:all_adjustments)
        .where(
          spree_adjustments: {
            source_type: "Spree::PromotionAction",
            source_id: actions.map(&:id),
            eligible: true
          }
        ).distinct
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
      started? && not_expired? && actions.present?
    end

    def inactive?
      !active?
    end

    def activate(order:, line_item: nil, user: nil, path: nil, promotion_code: nil)
      return unless self.class.order_activatable?(order)

      payload = {
        order:,
        promotion: self,
        line_item:,
        user:,
        path:,
        promotion_code:
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
          promotion_code:
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
      return false if usage_limit_exceeded?(excluded_orders:)
      return false if promotion_code&.usage_limit_exceeded?(excluded_orders:)

      !!eligible_rules(promotable, {})
    end

    # eligible_rules returns an array of promotion rules where eligible? is true for the promotable
    # if there are no such rules, an empty array is returned
    # if the rules make this promotable ineligible, then nil is returned (i.e. this promotable is not eligible)
    def eligible_rules(promotable, options = {})
      # Promotions without rules are eligible by default.
      return [] if rules.none?

      eligible = lambda { |rule| rule.eligible?(promotable, options) }
      specific_rules = rules.select { |rule| rule.applicable?(promotable) }
      return [] if specific_rules.none?

      # If there are rules for this promotion, but no rules for this
      # particular promotable, then the promotion is ineligible by default.
      unless specific_rules.all?(&eligible)
        @eligibility_errors = specific_rules.map(&:eligibility_errors).detect(&:present?)
        return nil
      end
      specific_rules
    end

    def products
      rules.where(type: "Spree::Promotion::Rules::Product").flat_map(&:products).uniq
    end

    # Whether the promotion has exceeded its usage restrictions.
    #
    # This method uses the usage claims counter, which is more efficient than
    # counting the number of completed orders that have used the promotion, but
    # it can drift from the actual usage count if the counter is not kept up to
    # date. Use `usage_limit_exceeded_from_orders?` to check against the actual
    # usage count.
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage limit
    # @return true or false
    def usage_limit_exceeded?(excluded_orders: [])
      usage_count(excluded_orders:) >= usage_limit if usage_limit
    end

    # Whether the promotion has exceeded its usage restrictions, based on the
    # actual usage count from completed orders.
    #
    # This method is less efficient than `usage_limit_exceeded?`, but does not
    # rely on the usage claims counter, which can drift from the actual usage
    # count if the counter is not kept up to date.
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage limit
    # @return true or false
    def usage_limit_exceeded_from_orders?(excluded_orders: [])
      usage_count_from_orders(excluded_orders:) >= usage_limit if usage_limit
    end

    # Number of times the promotion has been used overall
    #
    # If a usage limit is set, this method uses the usage claims counter. Which
    # is more efficient. Otherwise, it falls back to counting the number of
    # completed orders that have used the promotion.
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage count
    # @return [Integer] usage count
    def usage_count(excluded_orders: [])
      return usage_count_from_orders(excluded_orders:) unless usage_limit

      usage_claims_count_excluding(excluded_orders)
    end

    # Number of times the promotion has been used in completed orders
    #
    # This method will always count the number of completed orders that have
    # used the promotion, regardless of whether a usage limit is set. It is less
    # efficient than `usage_count`, but we need it to help backfill the usage
    # claims counter. It's also useful for checking usage of any promotions that
    # don't have a limit.
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage count
    # @return [Integer] usage count
    def usage_count_from_orders(excluded_orders: [])
      usage_orders
        .where.not(id: [excluded_orders.map(&:id)])
        .count
    end

    # Resets the usage claims counters of the promotion and its codes from
    # their recorded usage. The counters aren't kept up to date while there's
    # no usage limit, so this runs whenever a usage limit is added.
    def recalculate_usage_claims_counts
      recalculate_usage_claims_count
      codes.where.not(usage_claims_count: 0).update_all(usage_claims_count: 0)
      codes.where(id: order_promotions.select(:promotion_code_id)).find_each(&:recalculate_usage_claims_count)
    end

    def line_item_actionable?(order, line_item, promotion_code: nil)
      return false if blacklisted?(line_item)

      if eligible?(order, promotion_code:)
        rules = eligible_rules(order)
        rules.blank? || rules.all? { |rule| rule.actionable? line_item }
      else
        false
      end
    end

    def used_by?(user, excluded_orders = [])
      discounted_orders
        .complete
        .where.not(id: excluded_orders.map(&:id))
        .where(user:)
        .where.not(spree_orders: {state: :canceled})
        .exists?
    end

    # Removes a promotion and any adjustments or other side effects from an
    # order.
    # @param order [Spree::Order] the order to remove the promotion from.
    # @return [void]
    def remove_from(order)
      actions.each do |action|
        action.remove_from(order)
      end
      # NOTE: this destroys the join table entry, not the promotion itself
      order.promotions.destroy(self)
      order.order_promotions.reset
      order_promotions.reset
    end

    private

    def usage_orders
      discounted_orders
        .complete
        .where.not(spree_orders: {state: :canceled})
    end

    def blacklisted?(promotable)
      case promotable
      when Spree::LineItem
        !promotable.variant.product.promotionable?
      when Spree::Order
        ActiveRecord::Associations::Preloader.new(records: promotable.line_items, associations: {variant: :product}).call
        promotable.line_items.any? { |line_item| !line_item.variant.product.promotionable? }
      end
    end

    def normalize_blank_values
      self[:path] = nil if self[:path].blank?
    end

    def apply_automatically_disallowed_with_paths
      return unless apply_automatically

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
