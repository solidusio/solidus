# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  # @param page [GearedPagination::Page] The pagination page object.
  #
  # @param columns [Array<Hash>] The array of column definitions.
  # @option columns [Symbol|Proc|#to_s] :header The column header.
  # @option columns [Symbol|Proc|#to_s] :data The data accessor for the column.
  # @option columns [String] :class_name (optional) The class name for the column.
  #
  # @param batch_actions [Array<Hash>] The array of batch action definitions.
  # @option batch_actions [String] :display_name The batch action display name.
  # @option batch_actions [String] :icon The batch action icon.
  # @option batch_actions [String] :action The batch action path.
  # @option batch_actions [String] :method The batch action HTTP method for the provided path.
  #
  # @param footer [String] The content for the footer, e.g. pagination links.
  #
  # @param checkbox_componnent [Class] The checkbox component class (default: component("ui/forms/checkbox")).
  # @param button_component [Class] The button component class (default: component("ui/button")).
  # @param tab_component [Class] The tab component class (default: component("ui/tab")).
  def initialize(
    page:,
    columns: [],
    batch_actions: [],
    footer: nil,
    checkbox_componnent: component("ui/forms/checkbox"),
    button_component: component("ui/button"),
    tab_component: component("ui/tab")
  )
    @page = page
    @columns = columns.map { Column.new(**_1) }
    @batch_actions = batch_actions.map { BatchAction.new(**_1) }
    @model_class = page.records.model
    @rows = page.records
    @footer = footer

    @checkbox_componnent = checkbox_componnent
    @button_component = button_component
    @tab_component = tab_component

    @columns.unshift selectable_column if batch_actions.present?
  end

  def resource_plural_name
    @model_class.model_name.human.pluralize
  end

  def selectable_column
    @selectable_column ||= Column.new(
      header: -> {
        @checkbox_componnent.new(
          form: batch_actions_form_id,
          "data-action": "#{stimulus_id}#selectAllRows",
          "data-#{stimulus_id}-target": "headerCheckbox",
          "aria-label": t('.select_all'),
        )
      },
      data: ->(data) {
        @checkbox_componnent.new(
          name: "id[]",
          form: batch_actions_form_id,
          value: data.id,
          "data-action": "#{stimulus_id}#selectRow",
          "data-#{stimulus_id}-target": "checkbox",
          "aria-label": t('.select_row'),
        )
      },
      class_name: 'w-[52px]',
    )
  end

  def batch_actions_form_id
    @batch_actions_form_id ||= "#{stimulus_id}--batch-actions-#{SecureRandom.hex}"
  end

  def render_batch_action_button(batch_action)
    render @button_component.new(
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

  def render_header_cell(cell, **attrs)
    cell =
      case cell
      when Symbol
        @model_class.human_attribute_name(cell)
      when Proc
        cell.call
      else
        cell
      end

    # Allow component instances as cell content
    cell = cell.render_in(self) if cell.respond_to?(:render_in)

    content_tag(:th, cell, class: %{
      border-b
      border-gray-100
      px-4
      h-9
      font-semibold
      vertical-align-middle
      leading-none
    }, **attrs)
  end

  def render_data_cell(cell, data)
    cell =
      case cell
      when Symbol
        data.public_send(cell)
      when Proc
        cell.call(data)
      else
        cell
      end

    # Allow component instances as cell content
    cell = cell.render_in(self) if cell.respond_to?(:render_in)

    content_tag(:td, content_tag(:div, cell, class: "flex items-center gap-1.5"), class: "py-2 px-4 h-10 vertical-align-middle leading-none")
  end

  Column = Struct.new(:header, :data, :class_name, keyword_init: true)
  BatchAction = Struct.new(:display_name, :icon, :action, :method, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  private_constant :Column, :BatchAction
end
