# frozen_string_literal: true

module Spree
  module Api
    class ReturnAuthorizationsController < Spree::Api::BaseController
      before_action :load_order
      around_action :lock_order, only: [:create, :update, :destroy, :cancel]

      rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

      def create
        authorize! :create, ReturnAuthorization
        @return_authorization = @order.return_authorizations.build(return_authorization_params)
        if @return_authorization.save
          respond_with(@return_authorization, status: 201, default_template: :show)
        else
          invalid_resource!(@return_authorization)
        end
      end

      def destroy
        @return_authorization = @order.return_authorizations.accessible_by(current_ability, :destroy).find(params[:id])
        @return_authorization.destroy
        respond_with(@return_authorization, status: 204)
      end

      def index
        authorize! :admin, ReturnAuthorization

        @return_authorizations = @order
          .return_authorizations
          .accessible_by(current_ability)
          .ransack(params[:q])
          .result

        @return_authorizations = paginate(@return_authorizations)

        respond_with(@return_authorizations)
      end

      def new
        authorize! :admin, ReturnAuthorization
      end

      def show
        authorize! :admin, ReturnAuthorization
        @return_authorization = @order.return_authorizations.accessible_by(current_ability, :show).find(params[:id])
        respond_with(@return_authorization)
      end

      def update
        @return_authorization = @order.return_authorizations.accessible_by(current_ability, :update).find(params[:id])
        if @return_authorization.update(return_authorization_params)
          respond_with(@return_authorization, default_template: :show)
        else
          invalid_resource!(@return_authorization)
        end
      end

      def cancel
        @return_authorization = @order.return_authorizations.accessible_by(current_ability, :update).find(params[:id])
        if @return_authorization.cancel
          respond_with @return_authorization, default_template: :show
        else
          invalid_resource!(@return_authorization)
        end
      end

      private

      def load_order
        @order ||= Spree::Order.find_by!(number: order_id)
        authorize! :show, @order
      end

      def return_authorization_params
        params.require(:return_authorization).permit(permitted_return_authorization_attributes)
      end
    end
  end
end
