# frozen_string_literal: true

module Spree
  module Admin
    module ReimbursementTypeHelper
      def reimbursement_type_name(reimbursement_type)
        reimbursement_type.present? ? reimbursement_type.name.humanize : ''
      end
    end
  end
end
