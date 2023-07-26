# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  # @param model_class [ActiveModel::Translation] The model class used for translations.
  # @param rows [Array] The collection of objects that will be passed to columns for display.
  # @param search_key [Symbol] The key for searching.
  # @param search_url [String] The base URL for searching.
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
  # @param prev_page_link [String, nil] The link to the previous page.
  # @param next_page_link [String, nil] The link to the next page.
  #
  # @param pagination_component [Class] The pagination component class (default: component("ui/table/pagination")).
  # @param checkbox_componnent [Class] The checkbox component class (default: component("ui/forms/checkbox")).
  # @param button_component [Class] The button component class (default: component("ui/button")).
  # @param icon_component [Class] The icon component class (default: component("ui/icon")).
  # @param tab_component [Class] The tab component class (default: component("ui/tab")).
  def initialize(
    model_class:,
    rows:,
    search_key:,
    search_url:,
    columns: [],
    batch_actions: [],
    prev_page_link: nil,
    next_page_link: nil,
    pagination_component: component("ui/table/pagination"),
    checkbox_componnent: component("ui/forms/checkbox"),
    button_component: component("ui/button"),
    icon_component: component("ui/icon"),
    tab_component: component("ui/tab")
  )
    @columns = columns.map { Column.new(**_1) }
    @batch_actions = batch_actions.map { BatchAction.new(**_1) }
    @model_class = model_class
    @rows = rows
    @search_key = search_key
    @search_url = search_url
    @prev_page_link = prev_page_link
    @next_page_link = next_page_link

    @pagination_component = pagination_component
    @checkbox_componnent = checkbox_componnent
    @button_component = button_component
    @icon_component = icon_component
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

  def table_frame_id
    @table_frame_id ||= "#{stimulus_id}--table-frame"
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
    cell = cell.call if cell.respond_to?(:call)
    cell = @model_class.human_attribute_name(cell) if cell.is_a?(Symbol)
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
    cell = cell.call(data) if cell.respond_to?(:call)
    cell = data.public_send(cell) if cell.is_a?(Symbol)
    cell = cell.render_in(self) if cell.respond_to?(:render_in)

    content_tag(:td, content_tag(:div, cell, class: "flex items-center gap-1.5"), class: "py-2 px-4 h-10 vertical-align-middle leading-none")
  end

  Column = Struct.new(:header, :data, :class_name, keyword_init: true)
  BatchAction = Struct.new(:display_name, :icon, :action, :method, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  private_constant :Column, :BatchAction
end
