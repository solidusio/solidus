# frozen_string_literal: true

class SolidusAdmin::Taxonomies::Show::Taxon::Component < SolidusAdmin::BaseComponent
  def initialize(taxon:, taxonomy:, prefix:, indent: false)
    @taxon = taxon
    @taxonomy = taxonomy
    @prefix = prefix
    @indent = indent
  end

  def position
    @prefix.split(".").join(".")
  end

  def name
    @taxon.name
  end

  def list_data
    {
      controller: "sortable",
      sortable_handle_value: ".handle",
      sortable_response_kind_value: "turbo-stream",
      sortable_group_value: "taxonomy-#{@taxonomy.id}",
      sortable_parent_id: @taxon.id
    }
  end

  def container_attributes
    margins = @indent ? "ml-6" : "m-2"

    {
      id: dom_id(@taxon),
      class: "flex flex-col flex-grow items-stretch #{margins}",
      "data-sortable-url":
        SolidusAdmin::Engine.routes.url_helpers.move_taxonomy_taxon_path(@taxonomy, @taxon.id)
    }
  end
end
