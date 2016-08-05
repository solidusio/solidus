module Spree
  module Admin
    class PaymentMethodsController < ResourceController
      skip_before_action :load_resource, only: :create
      before_action :load_providers
      before_action :validate_payment_method_provider, only: [:create, :update]

      respond_to :html

      def create
        @payment_method = @payment_method_type.new(payment_method_params)
        @object = @payment_method
        invoke_callbacks(:create, :before)
        if @payment_method.save
          invoke_callbacks(:create, :after)
          flash[:success] = Spree.t(:successfully_created, resource: Spree.t(:payment_method))
          redirect_to edit_admin_payment_method_path(@payment_method)
        else
          invoke_callbacks(:create, :fails)
          respond_with(@payment_method)
        end
      end

      def update
        @payment_method = @payment_method.becomes(@payment_method_type)
        invoke_callbacks(:update, :before)

        attributes = payment_method_params
        attributes.each do |k, _v|
          if k.include?("password") && attributes[k].blank?
            attributes.delete(k)
          end
        end

        if @payment_method.update_attributes(attributes)
          invoke_callbacks(:update, :after)
          flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:payment_method))
          redirect_to edit_admin_payment_method_path(@payment_method)
        else
          invoke_callbacks(:update, :fails)
          respond_with(@payment_method)
        end
      end

      private

      def collection
        super.ordered_by_position
      end

      def load_providers
        @providers = PaymentMethod.providers.sort_by(&:name)
      end

      def validate_payment_method_provider
        requested_type = params[:payment_method].delete(:type)
        @payment_method_type = @providers.detect do |klass|
          klass.name == requested_type
        end
        if !@payment_method_type
          flash[:error] = Spree.t(:invalid_payment_provider)
          redirect_to new_admin_payment_method_path
        end
      end

      def payment_method_params
        superclass_params = params.require(:payment_method).permit!
        subclass_params = params[ActiveModel::Naming.param_key(@payment_method_type)] || ActionController::Parameters.new

        superclass_params = superclass_params.permit!
        subclass_params = subclass_params.permit!

        superclass_params.to_h.merge(subclass_params.to_h)
      end
    end
  end
end
