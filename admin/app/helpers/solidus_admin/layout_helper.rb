# frozen_string_literal: true

module SolidusAdmin
  # Helpers for the admin layout
  module LayoutHelper
    # @return [Symbol]
    def current_locale(backend: I18n)
      backend.locale
    end

    # @param store_name [String]
    # @param controller_name [String]
    # @return [String] HTML title
    def solidus_admin_title(store_name: current_store.name, controller_name: controller.controller_name)
      "#{store_name} - #{t("solidus_admin.#{controller_name}")}"
    end
  end
end
