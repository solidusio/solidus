# frozen_string_literal: true

class SolidusAdmin::UI::Table::Component < SolidusAdmin::BaseComponent
  # @param page [GearedPagination::Page] The pagination page object.
  # @param path [Proc] A callable object that generates the path for pagination links.
  # @param columns [Array<Hash>] The array of column definitions.
  # @option columns [Symbol|Proc|#to_s] :header The column header.
  # @option columns [Symbol|Proc|#to_s] :data The data accessor for the column.
  # @option columns [String] :class_name (optional) The class name for the column.
  # @param batch_actions [Array<Hash>] The array of batch action definitions.
  # @option batch_actions [String] :display_name The batch action display name.
  # @option batch_actions [String] :icon The batch action icon.
  # @option batch_actions [String] :action The batch action path.
  # @option batch_actions [String] :method The batch action HTTP method for the provided path.
  # @param pagination_component [Class] The pagination component class (default: component("ui/table/pagination")).
  def initialize(page:, path: nil, columns: [], batch_actions: [], pagination_component: component("ui/table/pagination"))
    @page = page
    @path = path
    @columns = columns.map { Column.new(**_1) }
    @batch_actions = batch_actions.map { BatchAction.new(**_1) }
    @pagination_component = pagination_component
    @model_class = page.records.model
    @rows = page.records

    @columns.unshift selectable_column if batch_actions.present?
  end

  def selectable_column
    @selectable_column ||= Column.new(
      header: -> {
        component('ui/forms/checkbox').new
      },
      data: ->(data) {
        component('ui/forms/checkbox').new
      },
      class_name: 'w-[52px]',
    )
  end

  def render_batch_action_button(batch_action)
    render component('ui/button').new(
      icon: batch_action.icon,
      text: batch_action.display_name,
      scheme: :secondary,
    )
  end

  def render_header_cell(cell)
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
    })
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

  Column = Struct.new(:header, :data, :class_name, keyword_init: true)
  BatchAction = Struct.new(:display_name, :icon, :action, :method, keyword_init: true) # rubocop:disable Lint/StructNewOverride
  private_constant :Column, :BatchAction
end
