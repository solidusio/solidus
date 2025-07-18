# frozen_string_literal: true

class SolidusAdmin::Zones::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Zone
  end

  def title
    t('solidus_admin.zones.title')
  end

  def search_key
    :name_or_description_cont
  end

  def search_url
    solidus_admin.zones_path
  end

  def edit_path(zone)
    solidus_admin.edit_zone_path(zone, **search_filter_params)
  end

  def turbo_frames
    %w[resource_form]
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_zone_path(**search_filter_params),
      data: { turbo_frame: :resource_form },
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
      name_column,
      description_column,
      kind_column,
      zone_members_column,
    ]
  end

  def name_column
    {
      header: :name,
      data: ->(zone) do
        link_to zone.name, edit_path(zone),
          data: { turbo_frame: :resource_form },
          class: 'body-link'
      end
    }
  end

  def description_column
    {
      header: :description,
      data: ->(zone) do
        link_to zone.description, edit_path(zone),
          data: { turbo_frame: :resource_form },
          class: 'body-link'
      end
    }
  end

  def kind_column
    {
      header: :kind,
      data: -> { component('ui/badge').new(name: _1.kind, color: _1.kind == 'country' ? :green : :blue) },
    }
  end

  def zone_members_column
    {
      header: :zone_members,
      data: -> { _1.zone_members.map(&:zoneable).map(&:name).to_sentence },
    }
  end
end
