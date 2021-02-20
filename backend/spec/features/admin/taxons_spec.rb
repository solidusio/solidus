# frozen_string_literal: true

require 'spec_helper'

describe "Taxonomies and taxons", type: :feature do
  stub_authorization!

  it "admin should be able to edit taxon" do
    visit spree.new_admin_taxonomy_path

    fill_in "Name", with: "Hello"
    click_button "Create"

    @taxonomy = Spree::Taxonomy.last

    visit spree.edit_admin_taxonomy_taxon_path(@taxonomy, @taxonomy.root.id)

    fill_in "taxon_name", with: "Shirt"
    fill_in "taxon_description", with: "Discover our new rails shirts"

    fill_in "permalink_part", with: "shirt-rails"
    click_button "Update"
    expect(page).to have_content("Taxon \"Shirt\" has been successfully updated!")
  end

  it "can view and add to taxon tree", js: true do
    taxonomy = create :taxonomy

    visit spree.edit_admin_taxonomy_path(taxonomy)
    expect(page).to have_content('Brand')

    click_on('Add taxon')
    expect(page).to have_content('New node')

    # Little tricky to select the right taxon. Since the text is technically
    # inside the top-level li.
    within '#taxonomy_tree li li', text: 'New node' do
      click_icon :edit
    end

    expect(page).to have_current_path %r{/admin/taxonomies/\d+/taxons/\d+/edit}
  end

  context "inside sidebar menu" do
    def only_one_selected_tab_inside?(sub_tab_selector, tab_name, tab_path)
      within(sub_tab_selector) do
        expect(page).to have_selector('.selected', count: 1)

        within('.selected') { expect(page).to have_link(tab_name, href: tab_path) }
      end
    end

    context "on display taxonomies page", js: true do
      it "should be selected only one tab 'Taxonomies' in product sub tabs" do
        visit spree.admin_taxonomies_path
        only_one_selected_tab_inside?('[data-hook=admin_product_sub_tabs]', 'Taxonomies', spree.admin_taxonomies_path)
      end
    end

    context "on edit taxonomy page", js: true do
      it "should be selected only one tab 'Taxonomies' in product sub tabs" do
        taxonomy = create :taxonomy

        visit spree.edit_admin_taxonomy_path(taxonomy)
        only_one_selected_tab_inside?('[data-hook=admin_product_sub_tabs]', 'Taxonomies', spree.admin_taxonomies_path)
      end
    end

    context "on edit taxonomy's taxon page", js: true do
      it "should be selected only one tab 'Taxonomies' in product sub tabs" do
        taxonomy = create :taxonomy

        visit spree.edit_admin_taxonomy_taxon_path(taxonomy, taxonomy.root.id)
        only_one_selected_tab_inside?('[data-hook=admin_product_sub_tabs]', 'Taxonomies', spree.admin_taxonomies_path)
      end
    end
  end

  scenario "Removes attachments from taxon" do
    taxon = create(:taxon)
    taxon.update(icon: File.new(file_fixture('ror_ringer.jpeg')))

    visit spree.edit_admin_taxonomy_taxon_path(taxon.taxonomy, taxon.id)
    within('#taxon_icon_field') do
      click_on 'Remove'
    end

    expect(page).to have_content("Icon has been successfully removed!")
  end
end
