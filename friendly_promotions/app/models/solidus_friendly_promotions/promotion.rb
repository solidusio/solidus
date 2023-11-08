# frozen_string_literal: true

module SolidusFriendlyPromotions
  class Promotion < Spree::Base
    belongs_to :category, class_name: "SolidusFriendlyPromotions::PromotionCategory",
      foreign_key: :promotion_category_id, optional: true
    belongs_to :original_promotion, class_name: "Spree::Promotion", optional: true
    has_many :rules, class_name: "SolidusFriendlyPromotions::PromotionRule", dependent: :destroy
    has_many :actions, class_name: "SolidusFriendlyPromotions::PromotionAction", dependent: :nullify
    has_many :codes, class_name: "SolidusFriendlyPromotions::PromotionCode", dependent: :destroy
    has_many :code_batches, class_name: "SolidusFriendlyPromotions::PromotionCodeBatch", dependent: :destroy
    has_many :order_promotions, class_name: "SolidusFriendlyPromotions::OrderPromotion", dependent: :destroy

    validates :name, :customer_label, presence: true
    validates :path, uniqueness: {allow_blank: true, case_sensitive: true}
    validates :usage_limit, numericality: {greater_than: 0, allow_nil: true}
    validates :per_code_usage_limit, numericality: {greater_than_or_equal_to: 0, allow_nil: true}
    validates :description, length: {maximum: 255}
    validate :apply_automatically_disallowed_with_paths

    scope :active, ->(time = Time.current) { has_actions.started_and_unexpired(time) }
    scope :advertised, -> { where(advertise: true) }
    scope :coupons, -> { joins(:codes).distinct }
    scope :started_and_unexpired, ->(time = Time.current) do
      table = arel_table

      where(table[:starts_at].eq(nil).or(table[:starts_at].lt(time)))
        .where(table[:expires_at].eq(nil).or(table[:expires_at].gt(time)))
    end
    scope :has_actions, -> do
      joins(:actions).distinct
    end

    enum lane: SolidusFriendlyPromotions.config.preferred_lanes

    def self.human_enum_name(enum_name, enum_value)
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
    end

    def self.lane_options
      ordered_lanes.map do |lane_name, _index|
        [human_enum_name(:lane, lane_name), lane_name]
      end
    end

    def self.ordered_lanes
      lanes.sort_by(&:last).to_h
    end

    self.allowed_ransackable_associations = ["codes"]
    self.allowed_ransackable_attributes = %w[name customer_label path promotion_category_id]
    self.allowed_ransackable_scopes = %i[active]

    # All orders that have been discounted using this promotion
    def discounted_orders
      Spree::Order
        .joins(:all_adjustments)
        .where(
          spree_adjustments: {
            source_type: "SolidusFriendlyPromotions::PromotionAction",
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
      discounted_orders
        .complete
        .where.not(id: [excluded_orders.map(&:id)])
        .where.not(spree_orders: {state: :canceled})
        .count
    end

    def used_by?(user, excluded_orders = [])
      discounted_orders
        .complete
        .where.not(id: excluded_orders.map(&:id))
        .where(user: user)
        .where.not(spree_orders: {state: :canceled})
        .exists?
    end

    # Whether the promotion has exceeded its usage restrictions.
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage limit
    # @return true or false
    def usage_limit_exceeded?(excluded_orders: [])
      return unless usage_limit

      usage_count(excluded_orders: excluded_orders) >= usage_limit
    end

    def not_expired?(time = Time.current)
      !expired?(time)
    end

    def not_started?(time = Time.current)
      !started?(time)
    end

    def started?(time = Time.current)
      starts_at.nil? || starts_at < time
    end

    def active?(time = Time.current)
      started?(time) && not_expired?(time) && actions.present?
    end

    def inactive?(time = Time.current)
      !active?(time)
    end

    def expired?(time = Time.current)
      expires_at.present? && expires_at < time
    end

    def products
      rules.where(type: "SolidusFriendlyPromotions::Rules::Product").flat_map(&:products).uniq
    end

    def eligibility_results
      @eligibility_results ||= SolidusFriendlyPromotions::EligibilityResults.new(self)
    end

    def eligible_by_applicable_rules?(promotable, dry_run: false)
      applicable_rules = rules.select do |rule|
        rule.applicable?(promotable)
      end

      applicable_rules.map do |applicable_rule|
        eligible = applicable_rule.eligible?(promotable)

        break [false] if !eligible && !dry_run

        if dry_run
          if applicable_rule.eligibility_errors.details[:base].first
            code = applicable_rule.eligibility_errors.details[:base].first[:error_code]
            message = applicable_rule.eligibility_errors.full_messages.first
          end
          eligibility_results.add(
            item: promotable,
            rule: applicable_rule,
            success: eligible,
            code: eligible ? nil : (code || :coupon_code_unknown_error),
            message: eligible ? nil : (message || I18n.t(:coupon_code_unknown_error, scope: [:solidus_friendly_promotions, :eligibility_errors]))
          )
        end

        eligible
      end.all?
    end

    private

    def apply_automatically_disallowed_with_paths
      return unless apply_automatically

      errors.add(:apply_automatically, :disallowed_with_path) if path.present?
    end
  end
end
