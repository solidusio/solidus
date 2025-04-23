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

  def edit_path(store)
    solidus_admin.edit_store_path(store)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_store_path,
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
        require_confirmation: true,
      },
    ]
  end

  def columns
    [
      name_column,
      url_column,
      slug_column,
      default_column,
    ]
  end

  private

  def name_column
    {
      header: :name,
      data: ->(store) do
        link_to store.name, edit_path(store), class: 'body-link'
      end
    }
  end

  def url_column
    {
      header: :url,
      data: ->(store) do
        link_to store.url, edit_path(store), class: 'body-link'
      end
    }
  end

  def slug_column
    {
      header: :slug,
      data: ->(store) do
        link_to store.code, edit_path(store), class: 'body-link'
      end
    }
  end

  def default_column
    {
      header: :default,
      data: ->(store) do
        store.default? ? component('ui/badge').yes : component('ui/badge').no
      end
    }
  end
end
