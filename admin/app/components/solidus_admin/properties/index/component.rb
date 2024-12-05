# frozen_string_literal: true

class SolidusAdmin::Properties::Index::Component < SolidusAdmin::UI::Pages::Index::Component
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
    edit_path(property)
  end

  def edit_path(property)
    spree.admin_property_path(property, **search_filter_params)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_property_path,
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
        link_to property.name, edit_path(property), class: "body-link"
      end
    }
  end

  def presentation_column
    {
      header: :presentation,
      data: ->(property) do
        link_to property.presentation, edit_path(property), class: "body-link"
      end
    }
  end
end
