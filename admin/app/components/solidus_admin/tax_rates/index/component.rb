# frozen_string_literal: true

class SolidusAdmin::TaxRates::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::TaxRate.model_name.human.pluralize
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
        action: solidus_admin.tax_rates_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def scopes
    []
  end

  def filters
    [
      {
        presentation: Spree::Zone.model_name.human,
        attribute: :zone_id,
        predicate: :eq,
        options: Spree::Zone.pluck(:name, :id),
      },
      {
        presentation: Spree::TaxCategory.model_name.human,
        attribute: :tax_categories_id,
        predicate: :in,
        options: Spree::TaxCategory.pluck(:name, :id),
      }
    ]
  end

  def columns
    [
      {
        header: :zone,
        data: -> { _1.zone&.name },
      },
      :name,
      {
        header: :tax_categories,
        data: -> { _1.tax_categories.map(&:name).join(', ') },
      },
      {
        header: :amount,
        data: -> { _1.display_amount },
      },
      {
        header: :included_in_price,
        data: -> { _1.included_in_price? ? component('ui/badge').yes : component('ui/badge').no },
      },
      {
        header: :show_rate_in_label,
        data: -> { _1.show_rate_in_label? ? component('ui/badge').yes : component('ui/badge').no },
      },
      :expires_at,
      {
        header: Spree::Calculator.model_name.human,
        data: -> { _1.calculator&.class&.model_name&.human }
      },
    ]
  end
end
