# frozen_string_literal: true

module Spree
  module Admin
    class PaymentMethodsController < ResourceController
      skip_before_action :load_resource, only: :create
      before_action :load_payment_method_types, except: [:index]
      before_action :validate_payment_method_type, only: [:create, :update]

      respond_to :html

      def create
        @payment_method = @payment_method_type.new(payment_method_params)
        @object = @payment_method
        invoke_callbacks(:create, :before)
        if @payment_method.save
          invoke_callbacks(:create, :after)
          flash[:success] = t('spree.successfully_created', resource: t('spree.payment_method'))
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
        attributes.each do |key, _value|
          if key.include?("password") && attributes[key].blank?
            attributes.delete(key)
          end
        end

        if @payment_method.update(attributes)
          invoke_callbacks(:update, :after)
          flash[:success] = t('spree.successfully_updated', resource: t('spree.payment_method'))
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
        Spree::Deprecation.warn('load_providers is deprecated. Please use load_payment_method_types instead.', caller)
        load_payment_method_types
      end

      def load_payment_method_types
        @payment_method_types = Rails.application.config.spree.payment_methods.sort_by(&:name)
        # TODO: Remove `@providers` instance var once `load_providers` gets removed.
        @providers = @payment_method_types
      end

      def validate_payment_provider
        Spree::Deprecation.warn('validate_payment_provider is deprecated. Please use validate_payment_method_type instead.', caller)
        validate_payment_method_type
      end

      def validate_payment_method_type
        requested_type = params[:payment_method][:type]
        @payment_method_type = @payment_method_types.detect do |klass|
          klass.name == requested_type
        end

        if !@payment_method_type
          flash[:error] = t('spree.invalid_payment_method_type')
          redirect_to new_admin_payment_method_path
        end
      end

      def payment_method_params
        params.require(:payment_method).permit!
      end
    end
  end
end
