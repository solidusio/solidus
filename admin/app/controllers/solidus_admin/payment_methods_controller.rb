# frozen_string_literal: true

module SolidusAdmin
  class PaymentMethodsController < SolidusAdmin::ResourcesController
    include SolidusAdmin::Moveable

    search_scope(:all)
    search_scope(:active, default: true, &:active)
    search_scope(:inactive) { _1.where.not(active: true) }
    search_scope(:storefront, &:available_to_users)
    search_scope(:admin, &:available_to_admin)

    private

    def resource_class = Spree::PaymentMethod

    def resources_collection = resource_class.all

    def resources_sorting_options = { position: :asc }

    def permitted_resource_params
      params.require(:payment_method).permit(:name, :description, :auto_capture, :type, :preference_source,
        :preferred_server, :preferred_test_mode, :active, :available_to_admin, :available_to_users, store_ids: [])
    end
  end
end
