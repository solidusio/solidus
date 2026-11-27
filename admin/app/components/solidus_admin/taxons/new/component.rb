# frozen_string_literal: true

class SolidusAdmin::Taxons::New::Component < SolidusAdmin::BaseComponent
  def initialize(taxon:, url:, frame:, target:, taxonomy: nil)
    @taxon = taxon
    @url = url
    @frame = frame
    @target = target
    @taxonomy = taxonomy
  end

  def selected_parent_option
    return [] unless (parent = @taxon.parent)

    [[parent.pretty_name, parent.id]]
  end

  def parent_select_attributes
    if @taxonomy
      {src: solidus_admin.pretty_names_taxons_path(taxonomy_id: @taxonomy.id)}
    else
      {include_blank: t(".none")}
    end
  end
end
