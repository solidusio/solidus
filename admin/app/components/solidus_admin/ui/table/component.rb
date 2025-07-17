# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  Column = Struct.new(:header, :data, :col, :wrap, keyword_init: true)
  Sortable = Struct.new(:url, :param, :animation, :handle, keyword_init: true)
  Scope = Struct.new(:label, :name, :default, keyword_init: true)
  Filter = Struct.new(:label, :combinator, :attribute, :predicate, :options, keyword_init: true)
  BatchAction = Struct.new(:label, :icon, :action, :require_confirmation, :method, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  private_constant :BatchAction, :Column, :Filter, :Scope, :Sortable

  class Data < Struct.new(:rows, :class, :url, :prev, :next, :columns, :fade, :batch_actions, :page, :per_page, keyword_init: true) # rubocop:disable Lint/StructNewOverride,Style/StructInheritance
    def initialize(**args)
      super

      self.columns = columns.map do |column|
        column.is_a?(Symbol) ? Column.new(wrap: false, header: column, data: column) : Column.new(wrap: false, **column)
      end
      self.batch_actions = batch_actions.to_a.map { |action| BatchAction.new(**action) }
    end

    def singular_name
      self[:class].model_name.human if self[:class]
    end

    def plural_name
      self[:class].model_name.human.pluralize if self[:class]
    end
  end

  class Search < Struct.new(:name, :value, :url, :searchbar_key, :scopes, :filters, keyword_init: true) # rubocop:disable Style/StructInheritance
    def initialize(**args)
      super

      self.filters = filters.to_a.map { |filter| Filter.new(**filter) }
      self.scopes = scopes.to_a.map { |scope| Scope.new(**scope) }
    end

    def current_scope
      scopes.find { |scope| scope.name.to_s == value[:scope].presence } || default_scope
    end

    def default_scope
      scopes.find(&:default)
    end

    def on_default_scope?
      current_scope == default_scope
    end

    def scope_param_name
      "#{name}[scope]"
    end

    def searchbar_param_name
      "#{name}[#{searchbar_key}]"
    end

    def value
      super || {}
    end
  end

  def initialize(id:, data:, search: nil, sortable: nil)
    @id = id
    @data = Data.new(**data)
    @data.columns.unshift selectable_column if @data.batch_actions.present? && @data.rows.present?
    @search = Search.new(**search) if search
    @sortable = Sortable.new(**sortable) if sortable
  end

  def selectable_column
    @selectable_column ||= Column.new(
      header: -> {
        component("ui/checkbox").new(
          form: batch_actions_form_id,
          "data-action": "#{stimulus_id}#selectAllRows",
          "data-#{stimulus_id}-target": "headerCheckbox",
          "aria-label": t('.select_all'),
        )
      },
      data: ->(data) {
        component("ui/checkbox").new(
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

  def search_form_id
    @search_form_id ||= "#{stimulus_id}--search-form-#{@id}"
  end

  def render_batch_action_button(batch_action)
    params = {
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
      text: batch_action.label,
      scheme: :secondary,
    }

    if batch_action.require_confirmation
      params["data-turbo-confirm"] = t(".are_you_sure")
      params["data-confirmation-template"] = t(
        ".action_confirmation",
        action: batch_action.label.downcase
      )
      params["data-confirm-button"] = batch_action.label
      params["data-resource-singular"] = @data.singular_name.downcase
      params["data-resource-plural"] = @data.plural_name.downcase
      params.merge! stimulus_target("batchActionButton")
    end

    render component("ui/button").new(**params)
  end

  def render_ransack_filter_dropdown(filter, index)
    render component("ui/table/ransack_filter").new(
      presentation: filter.label,
      search_param: @search.name,
      combinator: filter.combinator,
      attribute: filter.attribute,
      predicate: filter.predicate,
      options: filter.options,
      form: search_form_id,
      index:,
    )
  end

  def render_header_cell(cell, **attrs)
    cell = cell.call if cell.respond_to?(:call)
    cell = @data[:class].human_attribute_name(cell) if cell.is_a?(Symbol)
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
    cell = tag.div(cell, class: "flex items-center gap-1.5 justify-start overflow-x-hidden") if column.wrap

    tag.td(cell, class: "
      py-2 px-4 h-10 vertical-align-middle leading-none
      [tr:last-child_&:first-child]:rounded-bl-lg [tr:last-child_&:last-child]:rounded-br-lg
    ")
  end

  def current_scope_name
    @search.current_scope.name
  end

  def initial_mode
    @initial_mode ||=
      if @search && (@search.value[@search.searchbar_key] || @search.scopes.none?)
        "search"
      else
        "scopes"
      end
  end

  def should_enable_sortable?
    return false if @sortable.nil?
    return true if @search.nil?
    @search.on_default_scope?
  end
end
