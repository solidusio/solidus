# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  # @param id [String] A unique identifier for the table component.
  # @param model_class [ActiveModel::Translation] The model class used for translations.
  # @param rows [Array] The collection of objects that will be passed to columns for display.
  # @param fade_row_proc [Proc, nil] A proc determining if a row should have a faded appearance.
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
  #
  # @param filters [Array<Hash>] The array of filter definitions.
  # @option filters [String] :name The filter's name.
  # @option filters [Any] :value The filter's value.
  # @option filters [String] :label The filter's label.
  #
  # @param prev_page_link [String, nil] The link to the previous page.
  # @param next_page_link [String, nil] The link to the next page.
  def initialize(
    id:,
    model_class:,
    rows:,
    search_key:,
    search_url:,
    fade_row_proc: nil,
    columns: [],
    batch_actions: [],
    filters: [],
    prev_page_link: nil,
    next_page_link: nil
  )
    @columns = columns.map { Column.new(**_1) }
    @batch_actions = batch_actions.map { BatchAction.new(**_1) }
    @filters = filters.map { Filter.new(**_1) }
    @id = id
    @model_class = model_class
    @rows = rows
    @fade_row_proc = fade_row_proc
    @search_key = search_key
    @search_url = search_url
    @prev_page_link = prev_page_link
    @next_page_link = next_page_link

    @columns.unshift selectable_column if batch_actions.present?
  end

  def resource_plural_name
    @model_class.model_name.human.pluralize
  end

  def selectable_column
    @selectable_column ||= Column.new(
      header: -> {
        component("ui/forms/checkbox").new(
          form: batch_actions_form_id,
          "data-action": "#{stimulus_id}#selectAllRows",
          "data-#{stimulus_id}-target": "headerCheckbox",
          "aria-label": t('.select_all'),
        )
      },
      data: ->(data) {
        component("ui/forms/checkbox").new(
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
    @batch_actions_form_id ||= "#{stimulus_id}--batch-actions-#{@id}"
  end

  def table_frame_id
    @table_frame_id ||= "#{stimulus_id}--table-frame-#{@id}"
  end

  def search_form_id
    @search_form_id ||= "#{stimulus_id}--search-form-#{@id}"
  end

  def render_batch_action_button(batch_action)
    render component("ui/button").new(
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

  def row_class_for(row)
    classes = ['border-b', 'border-gray-100']
    classes << ['bg-gray-15', 'text-gray-700'] if @fade_row_proc&.call(row)

    classes.join(' ')
  end

  Column = Struct.new(:header, :data, :class_name, keyword_init: true)
  BatchAction = Struct.new(:display_name, :icon, :action, :method, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  Filter = Struct.new(:name, :value, :label, keyword_init: true)
  private_constant :Column, :BatchAction, :Filter
end
