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

  def country_select_options
    Spree::Country.order(:name).map { |c| [c.name, c.id] }
  end

  def default_zone_kind = :state

  def selected_state_select_options
    Spree::State.where(id: @zone.state_ids).map { |s| [s.state_with_country, s.id] }
  end
end
