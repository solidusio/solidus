# frozen_string_literal: true

class TaxonsController < StoreController
  helper 'spree/taxons', 'spree/products', 'taxon_filters'

  before_action :load_taxon, only: [:show]

  respond_to :html

  def show
    @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
    @products = @searcher.retrieve_products
  end

  private

  def load_taxon
    @taxon = Spree::Taxon.friendly.find(params[:id])
    redirect_to nested_taxons_path(@taxon), status: :moved_permanently if params[:id] != @taxon.permalink
  end

  def accurate_title
    if @taxon
      @taxon.seo_title
    else
      super
    end
  end
end
