# frozen_string_literal: true

class AutocompleteResultsController < StoreController
  def index
    respond_to do |format|
      format.html { redirect_to products_path(keywords: params[:keywords]) }
      format.turbo_stream { load_results }
    end
  end

  private

  def load_results
    @results ||= begin
      results = {}
      results[:products] = autocomplete_products
      results[:taxons] = autocomplete_taxons
      results
    end
  end

  def autocomplete_products
    if params[:keywords].present?
      searcher = build_searcher(params.merge(per_page: 5))
      searcher.retrieve_products
    else
      Spree::Product.none
    end
  end

  def autocomplete_taxons
    if params[:keywords].present?
      Spree::Taxon
        .where(Spree::Taxon.arel_table[:name].matches("%#{params[:keywords]}%"))
        .limit(5)
    else
      Spree::Taxon.none
    end
  end
end
