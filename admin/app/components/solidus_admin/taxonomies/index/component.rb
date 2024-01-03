# frozen_string_literal: true

class SolidusAdmin::Taxonomies::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Taxonomy
  end

  def row_url(taxonomy)
    spree.edit_admin_taxonomy_path(taxonomy)
  end

  def sortable_options
    {
      url: ->(taxonomy) { solidus_admin.move_taxonomy_path(taxonomy) },
      param: 'position',
    }
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_taxonomy_path,
      icon: "add-line",
    )
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
