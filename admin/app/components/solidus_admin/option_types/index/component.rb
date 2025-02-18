# frozen_string_literal: true

class SolidusAdmin::OptionTypes::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::OptionType
  end

  def row_url(option_type)
    spree.edit_admin_option_type_path(option_type)
  end

  def sortable_options
    {
      url: ->(option_type) { solidus_admin.move_option_type_path(option_type) },
      param: "position"
    }
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t(".add"),
      href: spree.new_admin_option_type_path,
      icon: "add-line"
    )
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    [
      {
        label: t(".batch_actions.delete"),
        action: solidus_admin.option_types_path,
        method: :delete,
        icon: "delete-bin-7-line"
      }
    ]
  end

  def columns
    [
      name_column,
      presentation_column
    ]
  end

  def name_column
    {
      header: :name,
      data: ->(option_type) do
        content_tag :div, option_type.name
      end
    }
  end

  def presentation_column
    {
      header: :presentation,
      data: ->(option_type) do
        content_tag :div, option_type.presentation
      end
    }
  end
end
