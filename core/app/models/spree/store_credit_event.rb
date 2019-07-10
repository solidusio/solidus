# frozen_string_literal: true

require 'discard'

module Spree
  class StoreCreditEvent < Spree::Base
    acts_as_paranoid
    include Spree::ParanoiaDeprecations

    include Discard::Model
    self.discard_column = :deleted_at

    belongs_to :store_credit, optional: true
    belongs_to :originator, polymorphic: true, optional: true
    belongs_to :store_credit_reason, class_name: 'Spree::StoreCreditReason', inverse_of: :store_credit_events, optional: true

    validates_presence_of :store_credit_reason, if: :action_requires_reason?

    NON_EXPOSED_ACTIONS = [Spree::StoreCredit::ELIGIBLE_ACTION, Spree::StoreCredit::AUTHORIZE_ACTION]

    scope :exposed_events, -> { exposable_actions.not_invalidated }
    scope :exposable_actions, -> { where.not(action: NON_EXPOSED_ACTIONS) }
    scope :not_invalidated, -> { joins(:store_credit).where(spree_store_credits: { invalidated_at: nil }) }
    scope :chronological, -> { order(:created_at) }
    scope :reverse_chronological, -> { order(created_at: :desc) }

    delegate :currency, to: :store_credit

    def capture_action?
      action == Spree::StoreCredit::CAPTURE_ACTION
    end

    def authorization_action?
      action == Spree::StoreCredit::AUTHORIZE_ACTION
    end

    def action_requires_reason?
      [Spree::StoreCredit::ADJUSTMENT_ACTION, Spree::StoreCredit::INVALIDATE_ACTION].include?(action)
    end

    def display_amount
      Spree::Money.new(amount, { currency: currency })
    end

    def display_user_total_amount
      Spree::Money.new(user_total_amount, { currency: currency })
    end

    def display_remaining_amount
      Spree::Money.new(amount_remaining, { currency: currency })
    end

    def display_event_date
      I18n.l(created_at.to_date, format: :long)
    end

    def display_action
      return if NON_EXPOSED_ACTIONS.include?(action)
      I18n.t("spree.store_credit.display_action.#{action}")
    end

    def order
      Spree::Payment.find_by(response_code: authorization_code).try(:order)
    end
  end
end
