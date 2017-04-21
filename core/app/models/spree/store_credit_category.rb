class Spree::StoreCreditCategory < Spree::Base
  class_attribute :non_expiring_credit_categories
  self.non_expiring_credit_categories = [Spree.t("store_credit_category.default")]

  class << self
    alias_attribute :non_expiring_credit_types, :non_expiring_credit_categories
    deprecate non_expiring_credit_types: :non_expiring_credit_categories, deprecator: Spree::Deprecation
    deprecate :non_expiring_credit_types= => :non_expiring_credit_categories=, deprecator: Spree::Deprecation
  end

  class_attribute :reimbursement_category_name
  self.reimbursement_category_name = Spree.t("store_credit_category.default")

  def self.reimbursement_category(_reimbursement)
    Spree::StoreCreditCategory.find_by(name: reimbursement_category_name) ||
      Spree::StoreCreditCategory.first
  end

  def non_expiring?
    self.class.non_expiring_credit_categories.include?(name)
  end
end
