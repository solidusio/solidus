# frozen_string_literal: true

module SolidusAdmin
  class PaymentMethodsController < SolidusAdmin::ResourcesController
    include SolidusAdmin::Moveable

    before_action :initialize_resource, only: [:new]
    before_action :validate_type, only: [:create, :update]
    before_action :change_type, only: [:update]

    search_scope(:all)
    search_scope(:active, default: true, &:active)
    search_scope(:inactive) { _1.where.not(active: true) }
    search_scope(:storefront, &:available_to_users)
    search_scope(:admin, &:available_to_admin)

    private

    def resource_class = Spree::PaymentMethod

    def resources_collection = resource_class.all

    def resources_sorting_options = {position: :asc}

    def permitted_resource_params
      params.require(:payment_method).permit(
        *permitted_attribute_params,
        *permitted_preference_params
      )
    end

    def permitted_attribute_params
      [
        :name,
        :description,
        :auto_capture,
        :type,
        :active,
        :available_to_admin,
        :available_to_users,
        :preference_source,
        store_ids: []
      ]
    end

    def permitted_preference_params
      return [] unless (type = params.dig(:payment_method, :type))
      return [] unless available_types.include?(type)

      type.constantize.new.options.keys.map { :"preferred_#{_1}" }
    end

    def initialize_resource
      @resource = resource_class.new(
        type: available_types.first,
        stores: [Spree::Store.default]
      )
    end

    def available_types
      Rails.application.config.spree.payment_methods.map(&:name).sort
    end

    def change_type
      return unless (new_type = params.dig(:payment_method, :type))
      return unless @resource.persisted? && @resource.type != new_type

      @resource = @resource.becomes(new_type.constantize)
      @resource.run_callbacks(:update, :before)
    end

    def validate_type
      return if available_types.include?(params[:payment_method][:type])

      @resource ||= resource_class.new(permitted_resource_params.except(:type))
      @resource.errors.add(:type, :invalid)

      page_component = @resource.persisted? ? edit_component.new(@resource) : new_component.new(@resource)
      render_resource_form_with_errors(page_component)
    end
  end
end
