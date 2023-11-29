# frozen_string_literal: true

class SolidusAdmin::OptionTypes::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(option_types:)
    @option_types = option_types
  end

  def title
    Spree::OptionType.model_name.human.pluralize
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

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.option_types_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end
end
