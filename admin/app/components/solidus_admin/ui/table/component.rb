require "solidus_admin/column"

# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  attr_reader :model_class

  # @param page [GearedPagination::Page] The pagination page object.
  # @param path [Proc] A callable object that generates the path for pagination links.
  # @param columns [Array<Hash>] The array of column definitions.
  # @option columns [Symbol|Proc|String] :header The column header.
  # @option columns [Symbol|Proc|String] :data The data accessor for the column.
  # @option columns [String] :class_name (optional) The class name for the column.
  # @param pagination_component [Class] The pagination component class (default: component("ui/table/pagination")).
  def initialize(page:, path: nil, columns: [], batch_actions: [], pagination_component: component("ui/table/pagination"), column_classes: {})
    @page = page
    @path = path
    @columns = columns
    @batch_actions = batch_actions.map { BatchAction.new(**_1) }
    @pagination_component = pagination_component
    @model_class = page.records.model
    @rows = page.records
    @column_classes = column_classes

    @columns.unshift selectable_column if batch_actions.present?
  end

  def selectable_column
    @selectable_column ||= SolidusAdmin::Column.new(
      name: :batch_actions,
      header: :batch_actions,
      renderer: ->(data) {
        component('ui/forms/checkbox').new(
          name: "id[]",
          form: batch_actions_form_id,
          value: data.id,
          "data-action": "#{stimulus_id}#selectRow",
          "data-#{stimulus_id}-target": "checkbox",
          "aria-label": t('.select_row'),
        )
      },
      render_context: self
    ).tap { |column| @column_classes[column.name] = 'w-[20px]' }
  end

  def batch_actions_header
    component('ui/forms/checkbox').new(
      form: batch_actions_form_id,
      "data-action": "#{stimulus_id}#selectAllRows",
      "data-#{stimulus_id}-target": "headerCheckbox",
      "aria-label": t('.select_all'),
    )
  end

  def batch_actions_form_id
    @batch_actions_form_id ||= "#{stimulus_id}--batch-actions-#{SecureRandom.hex}"
  end

  def render_batch_action_button(batch_action)
    render component('ui/button').new(
      name: request_forgery_protection_token,
      value: form_authenticity_token(form_options: {
        action: batch_action.action,
        method: batch_action.method,
      }),
      formaction: batch_action.action,
      formmethod: batch_action.method,
      form: batch_actions_form_id,
      type: :submit,
      icon: batch_action.icon,
      text: batch_action.display_name,
      scheme: :secondary,
    )
  end

  def render_cell(tag, cell, **attrs)
    # Allow component instances as cell content
    content_tag(tag, **attrs) do
      if cell.respond_to?(:render_in)
        cell.render_in(self)
      else
        cell.to_s
      end
    end
  end

  def render_header_cell(column)
    cell = column.render_header

    render_cell(:th, cell, class: %w[
      border-b
      border-gray-100
      py-3
      px-4
      text-[#4f4f4f]
      text-left
      text-3.5
      font-[600]
      line-[120%]
    ].join(" "))
  end

  def render_data_cell(column, row)
    cell = column.render_data(row)

    render_cell(:td, cell, class: "py-2 px-4")
  end

  def render_table_footer
    if @pagination_component
      tag.tfoot do
        tag.tr do
          tag.td(colspan: @columns.size, class: "py-4") do
            tag.div(class: "flex justify-center") do
              render_pagination_component
            end
          end
        end
      end
    end
  end

  def render_pagination_component
    @pagination_component.new(page: @page, path: @path).render_in(self)
  end

  BatchAction = Struct.new(:display_name, :icon, :action, :method, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  private_constant :BatchAction
end
