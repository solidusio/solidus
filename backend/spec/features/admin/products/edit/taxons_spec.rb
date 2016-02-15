require 'spec_helper'

describe "Product Taxons", :type => :feature do
  stub_authorization!

  after do
    Capybara.ignore_hidden_elements = true
  end

  before do
    Capybara.ignore_hidden_elements = false
  end

  context "managing taxons", js: true do
    def selected_taxons
      find("#product_taxon_ids").value.split(',').map(&:to_i).uniq
    end

    let(:product) { create(:product) }

    it "should allow an admin to manage taxons" do
      taxon_1 = create(:taxon)
      taxon_2 = create(:taxon, name: 'Clothing')
      product.taxons << taxon_1

      visit spree.admin_path
      click_link "Products"
      within("table.index") do
        click_icon :edit
      end

      expect(find(".select2-search-choice").text).to eq(taxon_1.name)
      expect(selected_taxons).to match_array([taxon_1.id])

      select2_search "Clothing", :from => "Taxons"
      click_button "Update"
      expect(selected_taxons).to match_array([taxon_1.id, taxon_2.id])

      # Regression test for #2139
      expect(page).to have_css(".select2-search-choice", text: taxon_1.name)
      expect(page).to have_css(".select2-search-choice", text: taxon_2.name)
    end

    context "with an XSS attempt" do
      let(:taxon_name) { %(<script>throw("XSS")</script>) }
      let!(:taxon) { create(:taxon, name: taxon_name) }
      it "displays the escaped HTML without executing it" do
        visit spree.edit_admin_product_path(product)

        select2_search "<script>", from: "Taxons"

        expect(page).to have_content(taxon_name)
      end
    end
  end
end
