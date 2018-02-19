# frozen_string_literal: true

class Spree::WalletPaymentSource < ActiveRecord::Base
  belongs_to :user, class_name: Spree::UserClassHandle.new, foreign_key: 'user_id', inverse_of: :wallet_payment_sources
  belongs_to :payment_source, polymorphic: true, inverse_of: :wallet_payment_sources

  validates_presence_of :user
  validates_presence_of :payment_source

  validate :check_for_payment_source_class

  private

  def check_for_payment_source_class
    if !payment_source.is_a?(Spree::PaymentSource)
      errors.add(:payment_source, :has_to_be_payment_source_class)
    end
  end
end
