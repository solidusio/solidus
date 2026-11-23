# frozen_string_literal: true

class SolidusAdmin::Taxonomies::Show::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(taxonomy:)
    @taxonomy = taxonomy
  end

  def title = @taxonomy.name

  def back_url = solidus_admin.taxonomies_path
end
