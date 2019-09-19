# frozen_string_literal: true

module Spree
  module Api
    class CreditCardsController < Spree::Api::BaseController
      before_action :user, only: [:index]
      before_action :find_credit_card, only: [:update]

      def index
        @credit_cards = user
          .credit_cards
          .accessible_by(current_ability, :read)
          .with_payment_profile
          .ransack(params[:q]).result

        @credit_cards = paginate(@credit_cards)
        respond_with(@credit_cards)
      end

      def update
        if @credit_card.update(credit_card_update_params)
          respond_with(@credit_card, default_template: :show)
        else
          invalid_resource!(@credit_card)
        end
      end

      private

      def user
        if params[:user_id].present?
          @user ||= Spree.user_class.accessible_by(current_ability, :read).find(params[:user_id])
        end
      end

      def find_credit_card
        @credit_card = Spree::CreditCard.find(params[:id])
        authorize! :update, @credit_card
      end

      def credit_card_update_params
        params.require(:credit_card).permit(permitted_credit_card_update_attributes)
      end
    end
  end
end
