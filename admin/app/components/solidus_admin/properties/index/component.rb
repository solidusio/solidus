# frozen_string_literal: true

class SolidusAdmin::Properties::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Property
  end

  def title
    t('solidus_admin.properties.title')
  end

  def search_key
    :name_cont
  end

  def search_url
    solidus_admin.properties_path
  end

  def edit_path(property)
    solidus_admin.edit_property_path(property, **search_filter_params)
  end

  def turbo_frames
    %w[resource_modal]
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_property_path(**search_filter_params),
      data: { turbo_frame: :resource_modal },
      icon: "add-line",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.properties_path(**search_filter_params),
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      name_column,
      presentation_column,
    ]
  end

  def name_column
    {
      header: :name,
      data: ->(property) do
        link_to property.name, edit_path(property),
          data: { turbo_frame: :resource_modal },
          class: 'body-link'
      end
    }
  end

  def presentation_column
    {
      header: :presentation,
      data: ->(property) do
        link_to property.presentation, edit_path(property),
          data: { turbo_frame: :resource_modal },
          class: 'body-link'
      end
    }
  end
end
