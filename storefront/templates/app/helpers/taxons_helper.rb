module TaxonsHelper
  def taxon_seo_url(taxon)
    nested_taxons_path(taxon.permalink)
  end
end
