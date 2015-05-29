child :children => :taxons do
  attributes *taxon_attributes

  extends "spree/api/taxons/taxons"
end
