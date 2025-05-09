# frozen_string_literal: true

class SolidusAdmin::Zones::Form::Component < SolidusAdmin::BaseComponent
  def initialize(zone:, form_url:, form_id:)
    @zone = zone
    @form_url = form_url
    @form_id = form_id
  end

  def title
    @zone.new_record? ? t(".title.new") : t(".title.edit")
  end
end
