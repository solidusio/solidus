child :children => :taxons do
  attributes *taxon_attributes

  extends "solidus/api/taxons/taxons"
end
