# frozen_string_literal: true

class SolidusAdmin::Properties::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def title
    t('solidus_admin.properties.title')
  end

  def model_class
    Spree::Property
  end

  def search_key
    :name_cont
  end

  def search_url
    solidus_admin.properties_path
  end

  def row_url(property)
    spree.admin_property_path(property)
  end

  def turbo_frames
    %w[
      new_property_modal
    ]
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_property_path,
      data: { turbo_frame: :new_property_modal },
      icon: "add-line",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.properties_path,
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
        content_tag :div, property.name
      end
    }
  end

  def presentation_column
    {
      header: :presentation,
      data: ->(property) do
        content_tag :div, property.presentation
      end
    }
  end
end
