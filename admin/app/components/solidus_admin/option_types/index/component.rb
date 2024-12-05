# frozen_string_literal: true

class SolidusAdmin::OptionTypes::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::OptionType
  end

  def row_url(option_type)
    edit_path(option_type)
  end

  def edit_path(option_type)
    spree.edit_admin_option_type_path(option_type, **search_filter_params)
  end

  def sortable_options
    {
      url: ->(option_type) { solidus_admin.move_option_type_path(option_type) },
      param: 'position',
    }
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_option_type_path,
      icon: "add-line",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.option_types_path,
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
      data: ->(option_type) do
        link_to option_type.name, edit_path(option_type), class: "body-link"
      end
    }
  end

  def presentation_column
    {
      header: :presentation,
      data: ->(option_type) do
        link_to option_type.presentation, edit_path(option_type), class: "body-link"
      end
    }
  end
end
