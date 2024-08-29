# frozen_string_literal: true

class SolidusAdmin::Roles::Edit::Component < SolidusAdmin::BaseComponent
  def initialize(page:, role:)
    @page = page
    @role = role
  end

  def form_id
    dom_id(@role, "#{stimulus_id}_edit_role_form")
  end
end
