# frozen_string_literal: true

class SolidusAdmin::TaxCategories::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::TaxCategory.model_name.human.pluralize
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
        action: solidus_admin.tax_categories_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def scopes
    []
  end

  def filters
    []
  end

  def columns
    [
      :name,
      :tax_code,
      :description,
      {
        header: :is_default,
        data: ->(tax_category) {
          if tax_category.is_default?
            component('ui/badge').new(name: t('.yes'), color: :green)
          else
            component('ui/badge').new(name: t('.no'), color: :graphite_light)
          end
        },
      },
    ]
  end
end
