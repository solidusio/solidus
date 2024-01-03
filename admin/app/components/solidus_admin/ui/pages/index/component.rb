# frozen_string_literal: true

class SolidusAdmin::UI::Pages::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  Tab = Struct.new(:text, :href, :current, keyword_init: true)

  def tabs
    nil
  end

  def initialize(page:)
    @page = page
    @tabs = tabs&.map { |tab| Tab.new(**tab) }
  end

  def row_fade(_record)
    false
  end

  def model_class
    nil
  end

  def title
    model_class.model_name.human.pluralize
  end

  def search_key
    nil
  end

  def search_params
    params[:q]
  end

  def search_name
    :q
  end

  def search_url
    nil
  end

  def table_id
    stimulus_id
  end

  def rows
    @page.records
  end

  def row_url(_record)
    nil
  end

  def batch_actions
    []
  end

  def scopes
    []
  end

  def filters
    []
  end

  def columns
    []
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def search_options
    return unless search_url

    {
      name: search_name,
      value: search_params,
      url: search_url,
      searchbar_key: search_key,
      filters: filters,
      scopes: scopes,
    }
  end

  def sortable_options
    nil
  end

  def render_table
    render component('ui/table').new(
      id: stimulus_id,
      data: {
        class: model_class,
        rows: rows,
        fade: -> { row_fade(_1) },
        prev: prev_page_path,
        next: next_page_path,
        columns: columns,
        batch_actions: batch_actions,
        url: -> { row_url(_1) },
      },
      search: search_options,
      sortable: sortable_options,
    )
  end

  def page_actions
    nil
  end
end
