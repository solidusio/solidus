# frozen_string_literal: true

module Spree
  module Admin
    class SettlementsController < BaseController
      before_action :load_settlement, only: [:accept, :reject]

      def accept
        @settlement.accept
        redirect_to location_after_save
      end

      def reject
        status = @settlement.acceptance_status
        @settlement.reject
        if status == 'accepted'
          @settlement.acceptance_status_errors = { settlement_manually_rejected: t('spree.settlement_manually_rejected') }
          @settlement.save
        end
        redirect_to location_after_save
      end

      private

      def load_settlement
        @settlement = Spree::Settlement.find params[:id]
      end

      def location_after_save
        url_for([:edit, :admin, @settlement.reimbursement.order, @settlement.reimbursement])
      end
    end
  end
end
