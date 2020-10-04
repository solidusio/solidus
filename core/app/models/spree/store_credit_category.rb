# frozen_string_literal: true

class Spree::StoreCreditCategory < Spree::Base
  class_attribute :non_expiring_credit_types
  self.non_expiring_credit_types = [Spree::StoreCreditType::NON_EXPIRING]

  class_attribute :reimbursement_category_name
  self.reimbursement_category_name = I18n.t('spree.store_credit_category.default')

  def self.reimbursement_category(_reimbursement)
    Spree::StoreCreditCategory.find_by(name: reimbursement_category_name) ||
      Spree::StoreCreditCategory.first
  end

  def non_expiring?
    self.class.non_expiring_credit_types.include? name
  end
end
