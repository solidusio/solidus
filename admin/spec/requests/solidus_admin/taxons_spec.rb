# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin::TaxonsController", type: :request do
  let(:admin_user) { create :admin_user }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController)
      .to receive(:spree_current_user)
      .and_return(admin_user)
  end

  describe "/admin/taxons/pretty_names" do
    subject { get "/admin/taxons/pretty_names" }

    let!(:taxonomy_b) { create :taxonomy, name: "Tree B", position: 999 }
    let!(:taxonomy_a) { create :taxonomy, name: "Tree A", position: 1 }

    let(:parent_a) { create :taxon, name: "Parent A", taxonomy_id: taxonomy_a.id, parent_id: taxonomy_a.root.id }
    let(:parent_b) { create :taxon, name: "Parent B", taxonomy_id: taxonomy_b.id, parent_id: taxonomy_b.root.id }

    let!(:taxon_a1) { create :taxon, name: "Child A1", taxonomy_id: taxonomy_a.id, parent_id: parent_a.id }
    let!(:taxon_a2) { create :taxon, name: "Child A2", taxonomy_id: taxonomy_a.id, parent_id: parent_a.id }
    let!(:taxon_b1) { create :taxon, name: "Child B1", taxonomy_id: taxonomy_b.id, parent_id: parent_b.id }
    let!(:taxon_b2) { create :taxon, name: "Child B2", taxonomy_id: taxonomy_b.id, parent_id: parent_b.id }

    it "returns the taxon trees in a deterministic order" do
      subject

      expect(JSON.parse(response.body)).to eq [
        {"id" => taxonomy_a.root.id, "pretty_name" => "Tree A"},
        {"id" => parent_a.id, "pretty_name" => "Tree A -> Parent A"},
        {"id" => taxon_a1.id, "pretty_name" => "Tree A -> Parent A -> Child A1"},
        {"id" => taxon_a2.id, "pretty_name" => "Tree A -> Parent A -> Child A2"},
        {"id" => taxonomy_b.root.id, "pretty_name" => "Tree B"},
        {"id" => parent_b.id, "pretty_name" => "Tree B -> Parent B"},
        {"id" => taxon_b1.id, "pretty_name" => "Tree B -> Parent B -> Child B1"},
        {"id" => taxon_b2.id, "pretty_name" => "Tree B -> Parent B -> Child B2"}
      ]
    end
  end
end
