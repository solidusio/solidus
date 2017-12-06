# frozen_string_literal: true

module Spree
  module Events
    class ReimbursementProcessedEvent
      attr_reader :reimbursement_id

      def initialize(reimbursement_id:)
        @reimbursement_id = reimbursement_id
      end
    end
  end
end
