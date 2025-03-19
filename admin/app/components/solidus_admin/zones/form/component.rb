# frozen_string_literal: true

class SolidusAdmin::Zones::Form::Component < SolidusAdmin::BaseComponent
  def initialize(zone:, title:, form_url:, form_id:)
    @zone = zone
    @title = title
    @form_url = form_url
    @form_id = form_id
  end
end
