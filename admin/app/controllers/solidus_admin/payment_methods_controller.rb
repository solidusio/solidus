# frozen_string_literal: true

module SolidusAdmin
  class PaymentMethodsController < SolidusAdmin::ResourcesController
    include SolidusAdmin::Moveable

    before_action :initialize_resource, only: [:new]
    before_action :validate_type, only: [:create, :update]

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
      params.require(:payment_method).permit(:name, :description, :auto_capture, :type, :preference_source,
        :preferred_server, :preferred_test_mode, :active, :available_to_admin, :available_to_users, store_ids: [])
    end

    def initialize_resource
      @resource = resource_class.new(stores: [Spree::Store.default])
    end

    def available_types
      Rails.application.config.spree.payment_methods.map(&:name)
    end

    def validate_type
      unless available_types.include?(params[:payment_method][:type])
        @resource ||= resource_class.new(permitted_resource_params.except(:type))
        @resource.errors.add(:type, :invalid)

        page_component = @resource.persisted? ? edit_component.new(@resource) : new_component.new(@resource)
        render_resource_form_with_errors(page_component)
      end
    end
  end
end
