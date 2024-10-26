# frozen_string_literal: true

module SolidusPromotions
  class Promotion < Spree::Base
    include Spree::SoftDeletable

    belongs_to :category, class_name: "SolidusPromotions::PromotionCategory",
      foreign_key: :promotion_category_id, optional: true
    belongs_to :original_promotion, class_name: "Spree::Promotion", optional: true
    has_many :benefits, class_name: "SolidusPromotions::Benefit", dependent: :destroy
    has_many :conditions, through: :benefits
    has_many :codes, class_name: "SolidusPromotions::PromotionCode", dependent: :destroy
    has_many :code_batches, class_name: "SolidusPromotions::PromotionCodeBatch", dependent: :destroy
    has_many :order_promotions, class_name: "SolidusPromotions::OrderPromotion", dependent: :destroy

    validates :name, :customer_label, presence: true
    validates :path, uniqueness: { allow_blank: true, case_sensitive: true }
    validates :usage_limit, numericality: { greater_than: 0, allow_nil: true }
    validates :per_code_usage_limit, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
    validates :description, length: { maximum: 255 }
    validate :apply_automatically_disallowed_with_paths
    validate :apply_automatically_disallowed_with_promotion_codes

    before_save :normalize_blank_values
    after_discard :delete_cart_connections

    scope :active, ->(time = Time.current) { has_benefits.started_and_unexpired(time) }
    scope :advertised, -> { where(advertise: true) }
    scope :coupons, -> { joins(:codes).distinct }
    scope :started_and_unexpired, ->(time = Time.current) do
      table = arel_table

      where(table[:starts_at].eq(nil).or(table[:starts_at].lt(time)))
        .where(table[:expires_at].eq(nil).or(table[:expires_at].gt(time)))
    end
    scope :has_benefits, -> do
      joins(:benefits).distinct
    end

    enum lane: SolidusPromotions.config.preferred_lanes

    def self.with_coupon_code(val)
      joins(:codes).where(
        SolidusPromotions::PromotionCode.arel_table[:value].eq(val.downcase)
      ).first
    end

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
    self.allowed_ransackable_attributes = %w[name customer_label path promotion_category_id lane updated_at]
    self.allowed_ransackable_scopes = %i[active with_discarded]

    # All orders that have been discounted using this promotion
    def discounted_orders
      Spree::Order
        .joins(:all_adjustments)
        .where(
          spree_adjustments: {
            source_type: "SolidusPromotions::Benefit",
            source_id: benefits.map(&:id)
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
        .where.not(spree_orders: { state: :canceled })
        .count
    end

    def used_by?(user, excluded_orders = [])
      discounted_orders
        .complete
        .where.not(id: excluded_orders.map(&:id))
        .where(user: user)
        .where.not(spree_orders: { state: :canceled })
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
      started?(time) && not_expired?(time) && benefits.present?
    end

    def inactive?(time = Time.current)
      !active?(time)
    end

    def expired?(time = Time.current)
      expires_at.present? && expires_at < time
    end

    def products
      conditions.where(type: "SolidusPromotions::Conditions::Product").flat_map(&:products).uniq
    end

    def eligibility_results
      @eligibility_results ||= SolidusPromotions::EligibilityResults.new(self)
    end

    private

    def normalize_blank_values
      self[:path] = nil if self[:path].blank?
    end

    def apply_automatically_disallowed_with_paths
      return unless apply_automatically

      errors.add(:apply_automatically, :disallowed_with_path) if path.present?
    end

    def apply_automatically_disallowed_with_promotion_codes
      return unless apply_automatically

      errors.add(:apply_automatically, :disallowed_with_promotion_codes) if codes.present?
    end

    def delete_cart_connections
      order_promotions.where(order: Spree::Order.incomplete).destroy_all
    end
  end
end
