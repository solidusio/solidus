module Spree
  class StoreCreditEvent < ActiveRecord::Base
    acts_as_paranoid

    belongs_to :store_credit
    belongs_to :originator, polymorphic: true

    scope :exposed_events, -> { exposable_actions.not_invalidated }
    scope :exposable_actions, -> { where.not(action: [Spree::StoreCredit::ELIGIBLE_ACTION, Spree::StoreCredit::AUTHORIZE_ACTION]) }
    scope :not_invalidated, -> { joins(:store_credit).where(spree_store_credits: { invalidated_at: nil }) }
    scope :reverse_chronological, -> { order(created_at: :desc) }

    delegate :currency, to: :store_credit

    def display_amount
      Spree::Money.new(amount, { currency: currency })
    end

    def display_user_total_amount
      Spree::Money.new(user_total_amount, { currency: currency })
    end

    def display_event_date
      I18n.l(created_at.to_date, format: :long)
    end

    def display_action
      case action
      when Spree::StoreCredit::CAPTURE_ACTION
        Spree.t('store_credit.captured')
      when Spree::StoreCredit::AUTHORIZE_ACTION
        Spree.t('store_credit.authorized')
      when Spree::StoreCredit::ALLOCATION_ACTION
        Spree.t('store_credit.allocated')
      when Spree::StoreCredit::VOID_ACTION, Spree::StoreCredit::CREDIT_ACTION
        Spree.t('store_credit.credit')
      end
    end

    def order
      Spree::Payment.find_by_response_code(authorization_code).try(:order)
    end
  end
end
