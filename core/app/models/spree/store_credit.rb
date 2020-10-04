# frozen_string_literal: true

class Spree::StoreCredit < Spree::PaymentSource
  include Spree::SoftDeletable

  VOID_ACTION       = 'void'
  CREDIT_ACTION     = 'credit'
  CAPTURE_ACTION    = 'capture'
  ELIGIBLE_ACTION   = 'eligible'
  AUTHORIZE_ACTION  = 'authorize'
  ALLOCATION_ACTION = 'allocation'
  ADJUSTMENT_ACTION = 'adjustment'
  INVALIDATE_ACTION = 'invalidate'

  belongs_to :user, class_name: Spree::UserClassHandle.new, optional: true
  belongs_to :created_by, class_name: Spree::UserClassHandle.new, optional: true
  belongs_to :category, class_name: "Spree::StoreCreditCategory", optional: true
  belongs_to :credit_type, class_name: 'Spree::StoreCreditType', foreign_key: 'type_id', optional: true
  has_many :store_credit_events

  validates_presence_of :user_id, :category_id, :type_id, :created_by_id, :currency
  validates_numericality_of :amount, { greater_than: 0 }
  validates_numericality_of :amount_used, { greater_than_or_equal_to: 0 }
  validate :amount_used_less_than_or_equal_to_amount
  validate :amount_authorized_less_than_or_equal_to_amount

  delegate :name, to: :category, prefix: true
  delegate :email, to: :created_by, prefix: true

  scope :order_by_priority, -> { includes(:credit_type).order('spree_store_credit_types.priority ASC') }

  after_save :store_event
  before_validation :associate_credit_type
  before_validation :validate_category_unchanged, on: :update
  before_destroy :validate_no_amount_used
  before_discard :validate_no_amount_used

  attr_accessor :action, :action_amount, :action_originator, :action_authorization_code, :store_credit_reason

  extend Spree::DisplayMoney
  money_methods :amount, :amount_used, :amount_authorized

  def amount_remaining
    return 0.0.to_d if invalidated?
    amount - amount_used - amount_authorized
  end

  def authorize(amount, order_currency, options = {})
    authorization_code = options[:action_authorization_code]
    if authorization_code
      if store_credit_events.find_by(action: AUTHORIZE_ACTION, authorization_code: authorization_code)
        # Don't authorize again on capture
        return true
      end
    else
      authorization_code = generate_authorization_code
    end

    if validate_authorization(amount, order_currency)
      update!({
        action: AUTHORIZE_ACTION,
        action_amount: amount,
        action_originator: options[:action_originator],
        action_authorization_code: authorization_code,

        amount_authorized: amount_authorized + amount
      })
      authorization_code
    else
      false
    end
  end

  def validate_authorization(amount, order_currency)
    if amount_remaining.to_d < amount.to_d
      errors.add(:base, I18n.t('spree.store_credit.insufficient_funds'))
    elsif currency != order_currency
      errors.add(:base, I18n.t('spree.store_credit.currency_mismatch'))
    end
    errors.blank?
  end

  def capture(amount, authorization_code, order_currency, options = {})
    return false unless authorize(amount, order_currency, action_authorization_code: authorization_code)
    auth_event = store_credit_events.find_by!(action: AUTHORIZE_ACTION, authorization_code: authorization_code)

    if amount <= auth_event.amount
      if currency != order_currency
        errors.add(:base, I18n.t('spree.store_credit.currency_mismatch'))
        false
      else
        update!({
          action: CAPTURE_ACTION,
          action_amount: amount,
          action_originator: options[:action_originator],
          action_authorization_code: authorization_code,

          amount_used: amount_used + amount,
          amount_authorized: amount_authorized - auth_event.amount
        })
        authorization_code
      end
    else
      errors.add(:base, I18n.t('spree.store_credit.insufficient_authorized_amount'))
      false
    end
  end

  def void(authorization_code, options = {})
    if auth_event = store_credit_events.find_by(action: AUTHORIZE_ACTION, authorization_code: authorization_code)
      update!({
        action: VOID_ACTION,
        action_amount: auth_event.amount,
        action_authorization_code: authorization_code,
        action_originator: options[:action_originator],

        amount_authorized: amount_authorized - auth_event.amount
      })
      true
    else
      errors.add(:base, I18n.t('spree.store_credit.unable_to_void', auth_code: authorization_code))
      false
    end
  end

  def credit(amount, authorization_code, order_currency, options = {})
    # Find the amount related to this authorization_code in order to add the store credit back
    capture_event = store_credit_events.find_by(action: CAPTURE_ACTION, authorization_code: authorization_code)

    if currency != order_currency # sanity check to make sure the order currency hasn't changed since the auth
      errors.add(:base, I18n.t('spree.store_credit.currency_mismatch'))
      false
    elsif capture_event && amount <= capture_event.amount
      action_attributes = {
        action: CREDIT_ACTION,
        action_amount: amount,
        action_originator: options[:action_originator],
        action_authorization_code: authorization_code
      }
      create_credit_record(amount, action_attributes)
      true
    else
      errors.add(:base, I18n.t('spree.store_credit.unable_to_credit', auth_code: authorization_code))
      false
    end
  end

  def can_void?(payment)
    payment.pending?
  end

  def generate_authorization_code
    "#{id}-SC-#{Time.current.utc.strftime('%Y%m%d%H%M%S%6N')}"
  end

  def editable?
    !amount_remaining.zero?
  end

  def invalidateable?
    !invalidated? && amount_authorized.zero?
  end

  def invalidated?
    !!invalidated_at
  end

  def update_amount(amount, reason, user_performing_update)
    previous_amount = self.amount
    self.amount = amount
    self.action_amount = self.amount - previous_amount
    self.action = ADJUSTMENT_ACTION
    self.store_credit_reason = reason
    self.action_originator = user_performing_update
    save
  end

  def invalidate(reason, user_performing_invalidation)
    if invalidateable?
      self.action = INVALIDATE_ACTION
      self.store_credit_reason = reason
      self.action_originator = user_performing_invalidation
      self.invalidated_at = Time.current
      save
    else
      errors.add(:invalidated_at, I18n.t('spree.store_credit.errors.cannot_invalidate_uncaptured_authorization'))
      false
    end
  end

  private

  def create_credit_record(amount, action_attributes = {})
    # Setting credit_to_new_allocation to true will create a new allocation anytime #credit is called
    # If it is not set, it will update the store credit's amount in place
    credit = if Spree::Config[:credit_to_new_allocation]
      Spree::StoreCredit.new(create_credit_record_params(amount))
    else
      self.amount_used = amount_used - amount
      self
    end

    credit.assign_attributes(action_attributes)
    credit.save!
  end

  def create_credit_record_params(amount)
    {
      amount: amount,
      user_id: user_id,
      category_id: category_id,
      created_by_id: created_by_id,
      currency: currency,
      type_id: type_id,
      memo: credit_allocation_memo
    }
  end

  def credit_allocation_memo
    I18n.t("spree.store_credit.credit_allocation_memo", id: id)
  end

  def store_event
    return unless saved_change_to_amount? || saved_change_to_amount_used? || saved_change_to_amount_authorized? || [ELIGIBLE_ACTION, INVALIDATE_ACTION].include?(action)

    event = if action
      store_credit_events.build(action: action)
    else
      store_credit_events.where(action: ALLOCATION_ACTION).first_or_initialize
    end

    event.update!({
      amount: action_amount || amount,
      authorization_code: action_authorization_code || event.authorization_code || generate_authorization_code,
      amount_remaining: amount_remaining,
      user_total_amount: user.available_store_credit_total(currency: currency),
      originator: action_originator,
      store_credit_reason: store_credit_reason
    })
  end

  def amount_used_less_than_or_equal_to_amount
    return true if amount_used.nil?

    if amount_used > amount
      errors.add(:amount_used, I18n.t('spree.admin.store_credits.errors.amount_used_cannot_be_greater'))
    end
  end

  def amount_authorized_less_than_or_equal_to_amount
    if (amount_used + amount_authorized) > amount
      errors.add(:amount_authorized, I18n.t('spree.admin.store_credits.errors.amount_authorized_exceeds_total_credit'))
    end
  end

  def validate_category_unchanged
    if category_id_changed?
      errors.add(:category, I18n.t('spree.admin.store_credits.errors.cannot_be_modified'))
    end
  end

  def validate_no_amount_used
    if amount_used > 0
      errors.add(:amount_used, 'is greater than zero. Can not delete store credit')
      throw :abort
    end
  end

  def associate_credit_type
    unless type_id
      credit_type_name =
        if category.try(:non_expiring?)
          Spree::StoreCreditType::NON_EXPIRING
        else
          Spree::StoreCreditType::EXPIRING
        end
      self.credit_type = Spree::StoreCreditType.find_by(name: credit_type_name)
    end
  end
end
