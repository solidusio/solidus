# frozen_string_literal: true

class SolidusAdmin::Resources::Edit::Component < SolidusAdmin::Resources::BaseComponent
  def form_id
    dom_id(@resource, "#{stimulus_id}_edit_#{resource_name}_form")
  end

  def form_url
    solidus_admin.send(:"#{resource_name}_path", @resource, **search_filter_params)
  end
end
