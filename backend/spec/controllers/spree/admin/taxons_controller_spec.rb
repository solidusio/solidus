# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::TaxonsController, type: :controller do
  stub_authorization!

  describe "#edit" do
    let!(:taxon) { create(:taxon) }

    it "finds existing taxon" do
      get :edit, params: { taxonomy_id: taxon.taxonomy, id: taxon.id }
      expect(response.status).to eq(200)
    end

    it "cannot find a non-existing taxon with existent taxonomy" do
      get :edit, params: { taxonomy_id: taxon.taxonomy, id: 'non-existent-taxon' }
      expect(response).to redirect_to(spree.admin_taxonomies_path)
      expect(flash[:error]).to eql("Taxon is not found")
    end

    it "cannot find a existing taxon with non-existent taxonomy" do
      get :edit, params: { taxonomy_id: 'non-existent-taxonomy', id: taxon.id }
      expect(response).to redirect_to(spree.admin_taxonomies_path)
      expect(flash[:error]).to eql("Taxon is not found")
    end
  end
end
