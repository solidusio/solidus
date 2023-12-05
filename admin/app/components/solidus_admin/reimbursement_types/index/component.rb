# frozen_string_literal: true

class SolidusAdmin::ReimbursementTypes::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::ReimbursementType.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    []
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
        data: ->(reimbursement_type) do
          reimbursement_type.active? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
