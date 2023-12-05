# frozen_string_literal: true

class SolidusAdmin::ReturnReasons::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::ReturnReason.model_name.human.pluralize
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
        action: solidus_admin.return_reasons_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def filters
    []
  end

  def scopes
    []
  end

  def columns
    [
      :name,
      {
        header: :active,
        data: ->(return_reason) do
          return_reason.active? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
