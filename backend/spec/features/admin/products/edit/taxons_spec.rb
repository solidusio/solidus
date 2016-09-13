require 'spec_helper'

describe "Product Display Order", type: :feature do
  stub_authorization!

  context "managing display order", js: true do
    def assert_selected_taxons(taxons)
      # Regression test for https://github.com/spree/spree/issues/2139
      taxons.each do |taxon|
        expect(page).to have_css(".select2-search-choice", text: taxon.name)
      end

      expected_value = taxons.map(&:id).join(",")
      expect(page).to have_xpath("//*[@id = 'product_taxon_ids' and @value = '#{expected_value}']", visible: :all)
    end

    let(:product) { create(:product) }

    it "should allow an admin to manage display order (taxons)" do
      taxon_1 = create(:taxon)
      taxon_2 = create(:taxon, name: 'Clothing')
      product.taxons << taxon_1

      visit spree.edit_admin_product_path(product)

      assert_selected_taxons([taxon_1])

      select2_search "Clothing", from: "Taxon"
      click_button "Update"
      assert_selected_taxons([taxon_1, taxon_2])
    end

    context "with an XSS attempt" do
      let(:taxon_name) { %(<script>throw("XSS")</script>) }
      let!(:taxon) { create(:taxon, name: taxon_name) }
      it "displays the escaped HTML without executing it" do
        visit spree.edit_admin_product_path(product)

        select2_search "<script>", from: "Taxon"

        expect(page).to have_content(taxon_name)
      end
    end
  end
end
