# frozen_string_literal: true

class SolidusAdmin::Stores::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Store
  end

  def search_key
    :name_or_url_or_code_cont
  end

  def search_url
    solidus_admin.stores_path
  end

  def row_url(store)
    spree.edit_admin_store_path(store)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_store_path,
      icon: "add-line",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.stores_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def columns
    [
      :name,
      :url,
      {
        header: :slug,
        data: ->(store) do
          content_tag :div, store.code
        end
      },
      {
        header: :default,
        data: ->(store) do
          store.default? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
