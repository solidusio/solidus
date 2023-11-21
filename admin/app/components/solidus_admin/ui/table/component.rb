# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  # @param id [String] A unique identifier for the table component.
  # @param model_class [ActiveModel::Translation] The model class used for translations.
  # @param rows [Array] The collection of objects that will be passed to columns for display.
  # @param row_fade [Proc, nil] A proc determining if a row should have a faded appearance.
  # @param row_url [Proc, nil] A proc that takes a row object as a parameter and returns the URL to navigate to when the row is clicked.
  # @param search_param [Symbol] The param for searching.
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
  # @param filters [Array<Hash>] The list of filter configurations to render.
  # @option filters [String] :presentation The display name of the filter dropdown.
  # @option filters [String] :combinator The combining logic of the filter dropdown.
  # @option filters [String] :attribute The database attribute this filter modifies.
  # @option filters [String] :predicate The predicate used for this filter (e.g., "eq" for equals).
  # @option filters [Array<Array>] :options An array of arrays, each containing two elements:
  #     1. A human-readable presentation of the filter option (e.g., "Active").
  #     2. The actual value used for filtering (e.g., "active").
  #
  # @param prev_page_link [String, nil] The link to the previous page.
  # @param next_page_link [String, nil] The link to the next page.
  def initialize(
    id:,
    model_class:,
    rows:,
    search_key:, search_url:, search_param: :q,
    row_fade: nil,
    row_url: nil,
    columns: [],
    batch_actions: [],
    filters: [],
    prev_page_link: nil,
    next_page_link: nil
  )
    @columns = columns.map { Column.new(wrap: true, **_1) }
    @batch_actions = batch_actions.map { BatchAction.new(**_1) }
    @filters = filters.map { Filter.new(**_1) }
    @id = id
    @model_class = model_class
    @rows = rows
    @row_fade = row_fade
    @row_url = row_url
    @search_param = search_param
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
      col: { class: 'w-[52px]' },
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

  def render_ransack_filter_dropdown(filter, index)
    render component("ui/table/ransack_filter").new(
      presentation: filter.presentation,
      search_param: @search_param,
      combinator: filter.combinator,
      attribute: filter.attribute,
      predicate: filter.predicate,
      options: filter.options,
      form: search_form_id,
      index: index,
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

  def render_data_cell(column, data)
    cell = column.data
    cell = cell.call(data) if cell.respond_to?(:call)
    cell = data.public_send(cell) if cell.is_a?(Symbol)
    cell = cell.render_in(self) if cell.respond_to?(:render_in)
    cell = tag.div(cell, class: "flex items-center gap-1.5 justify-start overflow-hidden") if column.wrap

    tag.td(cell, class: "
      py-2 px-4 h-10 vertical-align-middle leading-none
      [tr:last-child_&:first-child]:rounded-bl-lg [tr:last-child_&:last-child]:rounded-br-lg
    ")
  end

  Column = Struct.new(:header, :data, :col, :wrap, keyword_init: true)
  BatchAction = Struct.new(:display_name, :icon, :action, :method, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  Filter = Struct.new(:presentation, :combinator, :attribute, :predicate, :options, keyword_init: true)
  private_constant :Column, :BatchAction, :Filter
end
