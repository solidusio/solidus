# frozen_string_literal: true

class SolidusAdmin::OptionTypes::Edit::Component < SolidusAdmin::Resources::Edit::Component
  include SolidusAdmin::Layout::PageHelpers

  def render_option_values
    render component("ui/table").new(
      id: stimulus_id,
      data: {
        class: Spree::OptionValue,
        rows: @option_type.option_values,
        columns: option_value_columns,
        batch_actions: [
          {
            label: t('.panels.option_values.batch_actions.delete'),
            action: solidus_admin.option_values_path,
            method: :delete,
            icon: 'delete-bin-7-line',
            require_confirmation: true,
          },
        ]
      },
      sortable: {
        url: ->(option_value) { solidus_admin.move_option_value_path(option_value) },
        param: "position",
      },
      embedded: true,
    )
  end

  def option_value_columns
    [
      {
        header: :name,
        data: ->(option_value) do
          link_to option_value.name, solidus_admin.edit_option_value_path(option_value),
            class: 'body-link',
            data: { turbo_frame: :option_value_modal }
        end
      },
      {
        header: :presentation,
        data: ->(option_value) do
          link_to option_value.presentation, solidus_admin.edit_option_value_path(option_value),
            class: 'body-link',
            data: { turbo_frame: :option_value_modal }
        end
      },
    ]
  end
end
