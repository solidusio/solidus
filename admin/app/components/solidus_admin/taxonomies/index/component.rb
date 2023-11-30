# frozen_string_literal: true

class SolidusAdmin::Taxonomies::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(taxonomies:)
    @taxonomies = taxonomies
  end

  def title
    Spree::Taxonomy.model_name.human.pluralize
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
end
