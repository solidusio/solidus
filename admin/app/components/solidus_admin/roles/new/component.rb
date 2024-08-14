# frozen_string_literal: true

class SolidusAdmin::Roles::New::Component < SolidusAdmin::BaseComponent
  def initialize(page:, role:)
    @page = page
    @role = role
  end

  def form_id
    dom_id(@role, "#{stimulus_id}_new_role_form")
  end
end
