# frozen_string_literal: true

class SolidusAdmin::Roles::New::Component < SolidusAdmin::Resources::New::Component
  include SolidusAdmin::PermissionSetsHelper

  private

  def permission_set_options
    @permission_set_options ||= organize_permissions(permission_sets: Spree::PermissionSet.all, view_label: t(".view"), edit_label: t(".edit"))
  end
end
