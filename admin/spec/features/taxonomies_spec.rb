# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/moveable"

describe "Taxonomies", :js, type: :feature do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists taxonomies and allows deleting them" do
    create(:taxonomy, name: "Categories")
    create(:taxonomy, name: "Brand")

    visit "/admin/taxonomies"
    expect(page).to have_content("Categories")
    expect(page).to have_content("Brand")

    expect(page).to be_axe_clean

    select_row("Categories")
    click_on "Delete"
    expect(page).to have_content("Taxonomies were successfully removed.")
    expect(page).not_to have_content("Categories")
    expect(Spree::Taxonomy.count).to eq(1)
  end

  it_behaves_like "features: sortable" do
    let(:factory) { :taxonomy }
    let(:displayed_attribute) { :name }
    let(:path) { solidus_admin.taxonomies_path }
  end

  describe "taxonomy show page" do
    let!(:taxonomy) { create(:taxonomy, name: "Categories") }
    let!(:parent_a) { create(:taxon, name: "Parent A", taxonomy: taxonomy) }
    let!(:parent_b) { create(:taxon, name: "Parent B", taxonomy: taxonomy) }
    let!(:taxon_a1) { create(:taxon, name: "Child A1", taxonomy: taxonomy, parent: parent_a) }
    let!(:taxon_a2) { create(:taxon, name: "Child A2", taxonomy: taxonomy, parent: parent_a) }
    let!(:taxon_b1) { create(:taxon, name: "Child B1", taxonomy: taxonomy, parent: parent_b) }
    let!(:taxon_b2) { create(:taxon, name: "Child B2", taxonomy: taxonomy, parent: parent_b) }
    let!(:child_a1_1) { create(:taxon, name: "Grandchild A1-1", taxonomy: taxonomy, parent: taxon_a1) }

    it "allows sorting taxons via drag and drop and persists positions" do
      visit solidus_admin.taxonomy_path(taxonomy)

      expect(page).to have_content("1.1. Parent A")
      expect(page).to have_content("1.2. Parent B")

      taxon_handle("Parent B").drag_to taxon_handle("Parent A")

      expect(page).to have_content("1.1. Parent B")
      expect(page).to have_content("1.1.1. Child B1")
      expect(page).to have_content("1.2. Parent A")

      visit solidus_admin.taxonomy_path(taxonomy)
      expect(page).to have_content("1.1. Parent B")
      expect(page).to have_content("1.2. Parent A")
    end

    it "allows changing the depth of taxons via drag and drop and persists it" do
      visit solidus_admin.taxonomy_path(taxonomy)

      taxon_handle("Grandchild A1-1").drag_to taxon_handle("Child B1")
      expect(page).to have_content("1.2.2. Grandchild A1-1")

      taxon_handle("Child A2").drag_to taxon_handle("Child B2")
      expect(page).to have_content("1.2.4. Child A2")

      expect(child_a1_1.reload).to have_attributes(parent: parent_b, depth: 2)
      expect(taxon_a2.reload).to have_attributes(parent: parent_b, depth: 2)
      expect(parent_b.reload.children).to eq [taxon_b1, child_a1_1, taxon_b2, taxon_a2]
    end
  end

  def taxon_handle(name)
    find(:xpath, ".//li[./div//span[@role='listitem' and normalize-space()='#{name}']]/div//*[contains(@class, 'handle')]")
  end
end
