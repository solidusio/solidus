# frozen_string_literal: true

class SolidusAdmin::Taxonomies::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Taxonomy
  end

  def row_url(taxonomy)
    edit_path(taxonomy)
  end

  def edit_path(taxonomy)
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
        label: t('.batch_actions.delete'),
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
        link_to taxonomy.name, edit_path(taxonomy), class: "body-link"
      end
    }
  end
end
