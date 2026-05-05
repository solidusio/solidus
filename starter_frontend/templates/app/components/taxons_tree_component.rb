# frozen_string_literal: true

class TaxonsTreeComponent < ViewComponent::Base
  attr_reader :root_taxon, :title, :current_taxon, :max_level, :item_classes, :current_item_classes, :title_classes

  def initialize(
    root_taxon:,
    title: nil,
    current_taxon: nil,
    max_level: 1,
    item_classes: nil,
    current_item_classes: 'underline',
    title_classes: nil
  )
    @root_taxon = root_taxon
    @title = title
    @current_taxon = current_taxon
    @max_level = max_level
    @item_classes = item_classes
    @current_item_classes = current_item_classes
    @title_classes = title_classes
  end

  def call
    safe_join([header_tag, taxons_list].compact) if taxons_list
  end

  private

  def taxons_list
    @taxons_list ||= tree(root_taxon: root_taxon, item_classes: @item_classes, current_item_classes: @current_item_classes, max_level: max_level)
  end

  def all_taxon
    classes = item_classes
    classes = [classes, current_item_classes].join(' ') if current_page?(controller: 'products')

    content_tag :li, class: classes do
      link_to("All", products_path)
    end
  end

  def header_tag
    content_tag(:h6, title, class: title_classes) if title
  end

  def tree(root_taxon:, item_classes:, current_item_classes:, max_level:)
    return if max_level < 1 || root_taxon.children.empty?

    content_tag :ul do
      taxons = root_taxon.children.map do |taxon|
        classes = item_classes
        classes = [classes, current_item_classes].join(' ') if current_item_classes && current_taxon&.self_and_ancestors&.include?(taxon)

        content_tag :li, class: classes do
          link_to(taxon.name, helpers.taxon_seo_url(taxon)) +
            tree(root_taxon: taxon, item_classes: item_classes, current_item_classes: current_item_classes, max_level: max_level - 1)
        end
      end

      safe_join([taxons], "\n")
    end
  end
end
