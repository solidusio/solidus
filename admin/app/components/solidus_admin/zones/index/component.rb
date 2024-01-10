# frozen_string_literal: true

class SolidusAdmin::Zones::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Zone
  end

  def search_key
    :name_or_description_cont
  end

  def search_url
    solidus_admin.zones_path
  end

  def row_url(zone)
    spree.edit_admin_zone_path(zone)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_zone_path,
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.zones_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def scopes
    []
  end

  def filters
    []
  end

  def columns
    [
      :name,
      :description,
      {
        header: :kind,
        data: -> { component('ui/badge').new(name: _1.kind, color: _1.kind == 'country' ? :green : :blue) },
      },
      {
        header: :zone_members,
        data: -> { _1.zone_members.map(&:zoneable).map(&:name).to_sentence },
      },
    ]
  end
end
