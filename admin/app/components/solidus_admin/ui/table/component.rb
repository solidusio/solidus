# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  BatchAction = Struct.new(:display_name, :icon, :action, :method, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  Column = Struct.new(:header, :data, :col, :wrap, keyword_init: true)
  Filter = Struct.new(:presentation, :combinator, :attribute, :predicate, :options, keyword_init: true)
  private_constant :BatchAction, :Column, :Filter

  Data = Struct.new(:rows, :class, :url, :prev, :next, :columns, :fade, :batch_actions, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  Search = Struct.new(:name, :value, :url, :searchbar_key, :filters, :scopes, keyword_init: true)

  def initialize(id:, data:, search: nil)
    @id = id
    @data = Data.new(**data)
    @search = Search.new(**search)

    # Data
    @columns = @data.columns.map { Column.new(wrap: true, **_1) }
    @columns.unshift selectable_column if @data.batch_actions.present?
    @batch_actions = @data.batch_actions&.map { BatchAction.new(**_1) }
    @model_class = data[:class]
    @rows = @data.rows
    @row_fade = @data.fade
    @row_url = @data.url
    @prev_page_link = @data.prev
    @next_page_link = @data.next

    # Search
    @filters = @search.filters.map { Filter.new(**_1) }
    @search_param = @search.name
    @search_params = @search.value
    @search_key = @search.searchbar_key
    @search_url = @search.url
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


  def initial_mode
    @initial_mode ||= params.dig(@search_param, @search_key) ? "search" : "scopes"
  end
end
