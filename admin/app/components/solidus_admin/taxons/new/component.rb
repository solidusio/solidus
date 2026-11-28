# frozen_string_literal: true

class SolidusAdmin::Taxons::New::Component < SolidusAdmin::BaseComponent
  def initialize(taxon:, url:, frame:, target:, taxonomy: nil)
    @taxon = taxon
    @url = url
    @frame = frame
    @target = target
    @taxonomy = taxonomy
  end

  def form_id = dom_id(@taxon, :form)

  def slug_input_attributes
    if @taxon.persisted?
      {
        tag: :input,
        name: "#{@taxon.model_name.param_key}[permalink_part]",
        value: @taxon.permalink_part,
        prefix: ("#{@taxon.parent.permalink}/" if @taxon.parent)
      }
    else
      {tag: :input, readonly: true, placeholder: t(".slug_placeholder")}
    end
  end

  def parent_editable? = @taxon.new_record? || !@taxon.root?

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
