# frozen_string_literal: true

class SolidusAdmin::Roles::Edit::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::PermissionSetsHelper

  def initialize(page:, role:)
    @page = page
    @role = role
  end

  def form_id
    dom_id(@role, "#{stimulus_id}_edit_role_form")
  end

  private

  def permission_set_options
    @permission_set_options ||= organize_permissions(permission_sets: Spree::PermissionSet.all, view_label: t(".view"), edit_label: t(".edit"))
  end
end
