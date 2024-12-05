# frozen_string_literal: true

class SolidusAdmin::Products::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Product
  end

  def search_key
    :name_or_variants_including_master_sku_cont
  end

  def search_url
    solidus_admin.products_path
  end

  def row_url(product)
    edit_path(product)
  end

  def edit_path(product)
    solidus_admin.edit_product_path(product, **search_filter_params)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_product_path,
      icon: "add-line",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.products_path,
        method: :delete,
        icon: 'delete-bin-7-line',
        require_confirmation: true,
      },
      {
        label: t('.batch_actions.discontinue'),
        action: solidus_admin.discontinue_products_path,
        method: :put,
        icon: 'pause-circle-line',
        require_confirmation: true,
      },
      {
        label: t('.batch_actions.activate'),
        action: solidus_admin.activate_products_path,
        method: :put,
        icon: 'play-circle-line',
        require_confirmation: true,
      },
    ]
  end

  def scopes
    [
      { name: :all, label: t('.scopes.all'), default: true },
      { name: :in_stock, label: t('.scopes.in_stock') },
      { name: :out_of_stock, label: t('.scopes.out_of_stock') },
      { name: :available, label: t('.scopes.available') },
      { name: :discontinued, label: t('.scopes.discontinued') },
      { name: :deleted, label: t('.scopes.deleted') },
    ]
  end

  def filters
    Spree::OptionType.all.map do |option_type|
      {
        label: option_type.presentation,
        combinator: 'or',
        attribute: "option_values_id",
        predicate: "in",
        options: option_type.option_values.pluck(:name, :id),
      }
    end
  end

  def columns
    [
      image_column,
      name_column,
      status_column,
      price_column,
      stock_column,
    ]
  end

  def image_column
    {
      col: { class: "w-[72px]" },
      header: tag.span('aria-label': t('.image'), role: 'text'),
      data: ->(product) do
        image = product.gallery.images.first or return

        render(
          component('ui/thumbnail').new(
            src: image.url(:small),
            alt: product.name
          )
        )
      end
    }
  end

  def name_column
    {
      header: :name,
      data: ->(product) do
        link_to product.name, edit_path(product), class: "body-link"
      end
    }
  end

  def status_column
    {
      header: :status,
      data: ->(product) { component('products/status').from_product(product) }
    }
  end

  def stock_column
    {
      header: :stock,
      data: ->(product) { component('products/stock').from_product(product) }
    }
  end

  def price_column
    {
      header: :price,
      data: ->(product) do
        content_tag :div, product.master.display_price&.to_html
      end
    }
  end
end
