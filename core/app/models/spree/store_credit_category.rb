# frozen_string_literal: true

class Spree::StoreCreditCategory < Spree::Base
  GIFT_CARD = 'Gift Card'
  REIMBURSEMENT = 'Reimbursement'

  class_attribute :non_expiring_credit_types
  self.non_expiring_credit_types = [Spree::StoreCreditType::NON_EXPIRING]

  # @deprecated
  class_attribute :reimbursement_category_name
  self.reimbursement_category_name = I18n.t('spree.store_credit_category.default')

  # @deprecated
  def self.reimbursement_category(reimbursement)
    reimbursement.store_credit_category
  end

  def non_expiring?
    self.class.non_expiring_credit_types.include? name
  end

  public_instance_methods.grep(/^reimbursement_category_name/).each do |method|
    deprecate(
      method => 'Use Spree::Reimbursement#store_credit_category.name instead',
      deprecator: Spree::Deprecation
    )
  end

  class << self
    public_instance_methods.grep(/^reimbursement_category_name/).each do |method|
      deprecate(
        method => 'Use Spree::Reimbursement.store_credit_category.name instead',
        deprecator: Spree::Deprecation
      )
    end

    public_instance_methods.grep(/^reimbursement_category$/).each do |method|
      deprecate(
        method => 'Use Spree::Reimbursement.store_credit_category instead',
        deprecator: Spree::Deprecation
      )
    end
  end
end
