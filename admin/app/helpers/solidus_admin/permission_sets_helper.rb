# frozen_string_literal: true

module SolidusAdmin
  module PermissionSetsHelper
    # @param permission_sets [Array<Spree::PermissionSet>] an array of
    #   PermissionSet objects to be organized into categories based on their
    #   names.
    # @param view_label [String] A string of your choice associated with "View"
    #   or "Display" level permissions. Used when rendering the checkbox.
    # @param edit_label [String] A string of your choice associated with "Edit"
    #   or "Management" level permissions. Used when rendering the checkbox.
    def organize_permissions(permission_sets:, view_label:, edit_label:)
      return {} if permission_sets.blank?

      permission_sets.each_with_object({}) do |permission, grouped_permissions|
        group_key = permission.category.to_sym

        case permission.privilege
        when "display"
          grouped_permissions[group_key] ||= []
          grouped_permissions[group_key] << {label: view_label, id: permission.id}
        when "management"
          grouped_permissions[group_key] ||= []
          grouped_permissions[group_key] << {label: edit_label, id: permission.id}
        else
          grouped_permissions[:other] ||= []
          grouped_permissions[:other] << {label: permission.name, id: permission.id}
        end
      end
    end
  end
end
