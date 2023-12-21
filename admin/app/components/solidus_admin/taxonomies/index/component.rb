# frozen_string_literal: true

class SolidusAdmin::Taxonomies::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::Taxonomy.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.taxonomies_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      name_column,
    ]
  end

  def name_column
    {
      header: :name,
      data: ->(taxonomy) do
        content_tag :div, taxonomy.name
      end
    }
  end
end
