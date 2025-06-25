# frozen_string_literal: true

class SolidusAdmin::TaxRates::Index::Component < SolidusAdmin::Taxes::Component
  def row_url(tax_rate)
    spree.edit_admin_tax_rate_path(tax_rate)
  end

  def model_class
    Spree::TaxRate
  end

  def search_url
    solidus_admin.tax_rates_path
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_tax_rate_path,
      icon: "add-line",
      class: "align-self-end w-full",
    )
  end

  def search_key
    :name_or_description_cont
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.tax_rates_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def filters
    [
      {
        label: Spree::Zone.model_name.human,
        attribute: :zone_id,
        predicate: :eq,
        options: Spree::Zone.pluck(:name, :id),
      },
      {
        label: Spree::TaxCategory.model_name.human,
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
