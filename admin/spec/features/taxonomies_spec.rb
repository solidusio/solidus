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

  describe "adding a taxon" do
    let!(:taxonomy) { create(:taxonomy, name: "Categories") }
    let!(:parent_a) { create(:taxon, name: "Parent A", taxonomy: taxonomy) }
    let!(:taxon_a1) { create(:taxon, name: "Child A1", taxonomy: taxonomy, parent: parent_a) }

    it "adds a taxon to the root of the taxonomy by default" do
      visit solidus_admin.taxonomy_path(taxonomy)
      click_on "Add Category"

      within(dialog(text: "New Category")) do
        expect(page).to have_field("Slug", readonly: true, placeholder: "Slug will be generated after saving.")
        fill_in "Name", with: "Parent B"
        click_on "Add Category"
      end

      expect(page).to have_content("Category was successfully added.")
      expect(page).not_to have_css("dialog")
      expect(page).to have_content("1.2. Parent B")
      expect(taxonomy.root.children.last).to have_attributes(name: "Parent B", depth: 1)
    end

    it "adds a taxon under the selected parent" do
      visit solidus_admin.taxonomy_path(taxonomy)
      click_on "Add Category"

      within(dialog(text: "New Category")) do
        fill_in "Name", with: "Child A2"
        solidus_select "Categories -> Parent A", from: "Parent Category"
        click_on "Add Category"
      end

      expect(page).to have_content("1.1.2. Child A2")
      expect(parent_a.reload.children.last).to have_attributes(name: "Child A2", depth: 2)
    end

    it "adds a taxon under a row's taxon from its menu" do
      visit solidus_admin.taxonomy_path(taxonomy)

      row = taxon_row("Child A1").find("div", match: :first)
      row.find("summary").click
      row.click_on "Add new"

      within(dialog(text: "New Category")) do
        expect(solidus_select_control("Parent Category")).to have_text("Categories -> Parent A -> Child A1")
        fill_in "Name", with: "Grandchild A1-1"
        click_on "Add Category"
      end

      expect(page).to have_content("1.1.1.1. Grandchild A1-1")
      expect(taxon_a1.reload.children.last).to have_attributes(name: "Grandchild A1-1", depth: 3)
    end

    it "shows validation errors" do
      visit solidus_admin.taxonomy_path(taxonomy)
      click_on "Add Category"

      within(dialog(text: "New Category")) do
        click_on "Add Category"
      end

      expect(dialog(text: "New Category")).to have_content("can't be blank")
    end
  end

  describe "editing a taxon" do
    let!(:taxonomy) { create(:taxonomy, name: "Categories") }
    let!(:parent_a) { create(:taxon, name: "Parent A", taxonomy: taxonomy) }
    let!(:parent_b) { create(:taxon, name: "Parent B", taxonomy: taxonomy) }
    let!(:taxon_a1) { create(:taxon, name: "Child A1", taxonomy: taxonomy, parent: parent_a, description: "Old") }

    def open_edit_modal(name)
      row = taxon_row(name).find("div", match: :first)
      row.find("summary").click
      row.click_on "Edit"
    end

    it "edits a taxon" do
      visit solidus_admin.taxonomy_path(taxonomy)
      open_edit_modal("Child A1")

      within(dialog(text: "Edit Category")) do
        expect(page).to have_field("Name", with: "Child A1")
        expect(page).to have_content("categories/parent-a/")
        expect(page).to have_field("taxon[permalink_part]", with: "child-a1")
        expect(page).to have_field("taxon[description]", with: "Old")
        expect(solidus_select_control("Parent Category")).to have_text("Categories -> Parent A")

        fill_in "Name", with: "Renamed A1"
        fill_in "taxon[description]", with: "New"
        click_on "Save"
      end

      expect(page).to have_content("Category was successfully updated.")
      expect(page).not_to have_css("dialog")
      expect(page).to have_content("1.1.1. Renamed A1")
      expect(taxon_a1.reload).to have_attributes(name: "Renamed A1", description: "New")
    end

    it "edits the last part of a taxon's slug" do
      grandchild = create(:taxon, name: "Grandchild", taxonomy: taxonomy, parent: taxon_a1)

      visit solidus_admin.taxonomy_path(taxonomy)
      open_edit_modal("Child A1")

      within(dialog(text: "Edit Category")) do
        fill_in "taxon[permalink_part]", with: "whatever-i-want"
        click_on "Save"
      end

      expect(page).to have_content("Category was successfully updated.")
      expect(taxon_a1.reload.permalink).to eq "categories/parent-a/whatever-i-want"
      expect(grandchild.reload.permalink).to eq "categories/parent-a/whatever-i-want/grandchild"
    end

    it "moves a taxon to another parent" do
      visit solidus_admin.taxonomy_path(taxonomy)
      open_edit_modal("Child A1")

      within(dialog(text: "Edit Category")) do
        solidus_select "Categories -> Parent B", from: "Parent Category"
        click_on "Save"
      end

      expect(page).to have_content("1.2.1. Child A1")
      expect(taxon_a1.reload).to have_attributes(parent: parent_b, depth: 2)
    end

    it "shows validation errors" do
      visit solidus_admin.taxonomy_path(taxonomy)
      open_edit_modal("Child A1")

      within(dialog(text: "Edit Category")) do
        fill_in "Name", with: ""
        click_on "Save"
      end

      expect(dialog(text: "Edit Category")).to have_content("can't be blank")
    end

    it "does not offer changing the parent of the root taxon" do
      visit solidus_admin.taxonomy_path(taxonomy)
      open_edit_modal("Categories")

      within(dialog(text: "Edit Category")) do
        expect(page).to have_field("Name", with: "Categories")
        expect(page).not_to have_content("Parent Category")
      end
    end
  end

  describe "deleting a taxon" do
    let!(:taxonomy) { create(:taxonomy, name: "Categories") }
    let!(:parent_a) { create(:taxon, name: "Parent A", taxonomy: taxonomy) }
    let!(:taxon_a1) { create(:taxon, name: "Child A1", taxonomy: taxonomy, parent: parent_a) }
    let!(:taxon_a2) { create(:taxon, name: "Child A2", taxonomy: taxonomy, parent: parent_a) }
    let!(:child_a1_1) { create(:taxon, name: "Grandchild A1-1", taxonomy: taxonomy, parent: taxon_a1) }
    let!(:child_a1_2) { create(:taxon, name: "Grandchild A1-2", taxonomy: taxonomy, parent: taxon_a1) }

    it "deletes the taxon and moves its children up a level" do
      visit solidus_admin.taxonomy_path(taxonomy)

      within(taxon_row("Child A1").find("div", match: :first)) do
        find("summary").click
        click_on "Delete"
      end
      within("dialog", text: "Delete Child A1?") { click_on "Cancel" }
      expect(page).to have_content("1.1.1. Child A1")

      row = taxon_row("Child A1").find("div", match: :first)
      row.find("summary").click
      accept_turbo_confirm("Delete Child A1?") { row.click_on "Delete" }

      expect(page).not_to have_content("Child A1")
      expect(page).to have_content("1.1.1. Grandchild A1-1")
      expect(page).to have_content("1.1.2. Grandchild A1-2")
      expect(page).to have_content("1.1.3. Child A2")

      expect(Spree::Taxon.exists?(taxon_a1.id)).to eq false
      expect(child_a1_1.reload).to have_attributes(parent: parent_a, depth: 2)
      expect(child_a1_2.reload).to have_attributes(parent: parent_a, depth: 2)
    end

    it "does not offer deleting the root taxon" do
      visit solidus_admin.taxonomy_path(taxonomy)

      row = taxon_row("Categories").find("div", match: :first)
      row.find("summary").click

      expect(row).to have_link("Add new")
      expect(row).not_to have_button("Delete")
    end
  end

  def taxon_row(name)
    find(:xpath, ".//li[./div//span[@role='listitem' and normalize-space()='#{name}']]")
  end

  def taxon_handle(name)
    find(:xpath, ".//li[./div//span[@role='listitem' and normalize-space()='#{name}']]/div//*[contains(@class, 'handle')]")
  end
end
