# frozen_string_literal: true

class SolidusAdmin::UI::Pages::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  Tab = Struct.new(:text, :href, :current, keyword_init: true)

  # Template methods
  def tabs; end
  def model_class; end
  def back_url; end
  def search_key; end
  def search_url; end
  def page_actions; end
  def sidebar; end
  def sortable_options; end
  def row_url(_record); end
  def batch_actions; []; end
  def scopes; []; end
  def filters; []; end
  def columns; []; end

  def initialize(page:)
    @page = page
  end

  def row_fade(_record)
    false
  end

  def renderable_tabs
    return unless tabs

    tabs.map { |tab| Tab.new(**tab) }
  end

  def title
    I18n.t("activerecord.models.#{model_class.model_name.i18n_key}", count: 2)
  end

  def search_params
    params[:q]
  end

  def search_name
    :q
  end

  def rows
    @page.records
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
      filters:,
      scopes:,
    }
  end

  def render_title
    back_url = self.back_url

    safe_join [
      (page_header_back back_url if back_url),
      page_header_title(title),
    ]
  end

  def render_table
    render component('ui/table').new(
      id: stimulus_id,
      data: {
        class: model_class,
        rows:,
        fade: -> { row_fade(_1) },
        prev: prev_page_path,
        next: next_page_path,
        columns:,
        batch_actions:,
        url: -> { row_url(_1) },
        page: @page.number,
        per_page: @page.recordset.ratios.fixed,
      },
      search: search_options,
      sortable: sortable_options,
    )
  end

  def render_sidebar
    sidebar = self.sidebar

    page_with_sidebar_aside { sidebar } if sidebar
  end

  def turbo_frames
    []
  end
end
