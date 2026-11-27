# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::TaxonomyTaxonsController", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:taxonomy) { create(:taxonomy) }
  let(:root) { taxonomy.root }
  let!(:parent_a) { create(:taxon, name: "Parent A", taxonomy:, parent: root) }
  let!(:parent_b) { create(:taxon, name: "Parent B", taxonomy:, parent: root) }
  let!(:child_a1) { create(:taxon, name: "Child A1", taxonomy:, parent: parent_a) }
  let!(:child_a2) { create(:taxon, name: "Child A2", taxonomy:, parent: parent_a) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  def move(taxon, **params)
    patch solidus_admin.move_taxonomy_taxon_path(taxonomy, taxon.id, format: :turbo_stream), params:
  end

  describe "PATCH /move" do
    it "reorders a taxon within its parent" do
      move(parent_b, position: 1)

      expect(response).to have_http_status(:ok)
      expect(root.reload.children).to eq [parent_b, parent_a]
    end

    it "responds with the re-rendered taxon tree" do
      move(parent_b, position: 1)

      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include(%(<turbo-stream action="replace" target="taxon_#{root.id}">))
      expect(response.body).to match(/1\.1\.<\/span>\s*<span role="listitem">Parent B/)
    end

    it "moves a taxon to a different parent and updates its depth" do
      move(child_a2, position: 1, parent_id: parent_b.id)

      expect(response).to have_http_status(:ok)
      expect(child_a2.reload).to have_attributes(parent: parent_b, depth: 2)
      expect(parent_a.reload.children).to eq [child_a1]
    end

    it "moves a taxon deeper into the tree" do
      move(parent_b, position: 1, parent_id: child_a1.id)

      expect(response).to have_http_status(:ok)
      expect(parent_b.reload).to have_attributes(parent: child_a1, depth: 3)
    end

    it "updates the permalink of a moved taxon" do
      move(child_a2, position: 1, parent_id: parent_b.id)

      expect(child_a2.reload.permalink).to eq "#{parent_b.permalink}/child-a2"
    end

    it "does not allow moving a taxon into a different taxonomy" do
      other_taxon = create(:taxon)

      expect {
        move(child_a2, position: 1, parent_id: other_taxon.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(child_a2.reload.parent).to eq parent_a
    end
  end

  describe "GET /new" do
    it "renders the new taxon form" do
      get solidus_admin.new_taxonomy_taxon_path(taxonomy)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("New Category")
      expect(response.body).to include(solidus_admin.pretty_names_taxons_path(taxonomy_id: taxonomy.id))
    end
  end

  describe "GET /new with a parent" do
    it "pre-selects the given parent" do
      get solidus_admin.new_taxonomy_taxon_path(taxonomy, parent_id: child_a1.id)

      expect(response.body).to include(%(<option selected="selected" value="#{child_a1.id}">#{CGI.escapeHTML(child_a1.pretty_name)}</option>))
    end

    it "ignores a parent from another taxonomy" do
      other_taxon = create(:taxon)

      get solidus_admin.new_taxonomy_taxon_path(taxonomy, parent_id: other_taxon.id)

      expect(response.body).to include(%(<option selected="selected" value="#{root.id}">))
    end
  end

  describe "POST /create" do
    def create_taxon(**attributes)
      post solidus_admin.taxonomy_taxons_path(taxonomy), params: {taxon: attributes}
    end

    it "creates a taxon under the given parent" do
      create_taxon(name: "Child A3", parent_id: parent_a.id)

      expect(response).to redirect_to(solidus_admin.taxonomy_path(taxonomy))
      expect(response).to have_http_status(:see_other)
      expect(parent_a.reload.children.last).to have_attributes(name: "Child A3", taxonomy:)
    end

    it "creates a taxon under the root when no parent is given" do
      create_taxon(name: "Parent C")

      expect(root.reload.children.last).to have_attributes(name: "Parent C", depth: 1)
    end

    it "does not create a taxon under a parent from another taxonomy" do
      other_taxon = create(:taxon)

      create_taxon(name: "Parent C", parent_id: other_taxon.id)

      expect(other_taxon.reload.children).to be_empty
      expect(root.reload.children.last).to have_attributes(name: "Parent C")
    end

    it "responds with unprocessable entity when invalid" do
      expect { create_taxon(name: "") }.not_to change(Spree::Taxon, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /destroy" do
    let!(:grandchild_a1_1) { create(:taxon, name: "Grandchild A1-1", taxonomy:, parent: child_a1) }
    let!(:grandchild_a1_2) { create(:taxon, name: "Grandchild A1-2", taxonomy:, parent: child_a1) }

    def destroy(taxon)
      delete solidus_admin.taxonomy_taxon_path(taxonomy, taxon.id, format: :turbo_stream)
    end

    it "deletes the taxon" do
      expect { destroy(child_a1) }.to change(Spree::Taxon, :count).by(-1)
      expect(Spree::Taxon.exists?(child_a1.id)).to eq false
    end

    it "moves the taxon's children up a level in its place" do
      destroy(child_a1)

      expect(parent_a.reload.children).to eq [grandchild_a1_1, grandchild_a1_2, child_a2]
      expect(grandchild_a1_1.reload).to have_attributes(depth: 2, permalink: "#{parent_a.permalink}/grandchild-a1-1")
      expect(grandchild_a1_2.reload).to have_attributes(depth: 2, permalink: "#{parent_a.permalink}/grandchild-a1-2")
    end

    it "responds with the re-rendered taxon tree" do
      destroy(child_a1)

      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include(%(<turbo-stream action="replace" target="taxon_#{root.id}">))
      expect(response.body).not_to include("Child A1")
    end

    it "does not allow deleting the root taxon" do
      expect { destroy(root) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Spree::Taxon.exists?(root.id)).to eq true
    end
  end
end
