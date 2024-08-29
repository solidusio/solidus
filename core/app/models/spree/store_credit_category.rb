# frozen_string_literal: true

class Spree::StoreCreditCategory < Spree::Base
  GIFT_CARD = "Gift Card"
  REIMBURSEMENT = "Reimbursement"

  class_attribute :non_expiring_credit_types
  self.non_expiring_credit_types = [Spree::StoreCreditType::NON_EXPIRING]

  def non_expiring?
    self.class.non_expiring_credit_types.include? name
  end
end
