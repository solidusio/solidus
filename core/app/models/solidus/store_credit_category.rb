class Solidus::StoreCreditCategory < Solidus::Base
  class_attribute :non_expiring_credit_types
  self.non_expiring_credit_types = [Spree.t("store_credit.non_expiring")]

  class_attribute :reimbursement_category_name
  self.reimbursement_category_name = Spree.t("store_credit_category.default")

  def self.reimbursement_category(reimbursement)
    Solidus::StoreCreditCategory.find_by(name: reimbursement_category_name) ||
      Solidus::StoreCreditCategory.first
  end

  def non_expiring?
    self.class.non_expiring_credit_types.include? name
  end

end
