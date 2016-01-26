require 'spec_helper'

describe "Product Taxons", type: :feature do
  stub_authorization!

  context "managing taxons" do
    def assert_selected_taxons(taxons)
      # Regression test for https://github.com/spree/spree/issues/2139
      taxons.each do |taxon|
        expect(page).to have_css(".select2-search-choice", text: taxon.name)
      end

      expected_value = taxons.map(&:id).join(",")
      expect(page).to have_xpath("//*[@id = 'product_taxon_ids' and @value = '#{expected_value}']", visible: :all)
    end

    it "should allow an admin to manage taxons", js: true do
      taxon_1 = create(:taxon)
      taxon_2 = create(:taxon, name: 'Clothing')
      product = create(:product)
      product.taxons << taxon_1

      visit spree.edit_admin_product_path(product)

      assert_selected_taxons([taxon_1])

      select2_search "Clothing", from: "Taxons"
      click_button "Update"
      assert_selected_taxons([taxon_1, taxon_2])
    end
  end
end
