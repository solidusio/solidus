# frozen_string_literal: true

class Solidus::StoreCreditCategory < Solidus::Base
  class_attribute :non_expiring_credit_types
  self.non_expiring_credit_types = [Solidus::StoreCreditType::NON_EXPIRING]

  class_attribute :reimbursement_category_name
  self.reimbursement_category_name = I18n.t('spree.store_credit_category.default')

  def self.reimbursement_category(_reimbursement)
    Solidus::StoreCreditCategory.find_by(name: reimbursement_category_name) ||
      Solidus::StoreCreditCategory.first
  end

  def non_expiring?
    self.class.non_expiring_credit_types.include? name
  end
end
