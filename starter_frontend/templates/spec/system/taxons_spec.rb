# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'viewing products', type: :system do
  let!(:taxonomy) { create(:taxonomy, name: "Category") }
  let!(:super_clothing) { create(:taxon, name: "Super Clothing", parent: taxonomy.root, taxonomy: taxonomy) }
  let!(:t_shirts) { create(:taxon, name: "T-Shirts", parent: super_clothing, taxonomy: taxonomy) }
  let!(:xxl) { create(:taxon, name: "XXL", parent: t_shirts, taxonomy: taxonomy) }
  let!(:product) do
    product = create(:product, name: "Superman T-Shirt")
    product.taxons << t_shirts
  end
  let(:metas) { { meta_description: 'Brand new Ruby on Rails TShirts', meta_title: "Ruby On Rails TShirt", meta_keywords: 'ror, tshirt, ruby' } }
  let(:store_name) do
    ((first_store = Spree::Store.first) && first_store.name).to_s
  end

  # Regression test for https://github.com/spree/spree/issues/1796
  it "can see a taxon's products, even if that taxon has child taxons" do
    visit '/t/category/super-clothing/t-shirts'
    expect(page).to have_content("Superman T-Shirt")
  end

  it "shouldn't show nested taxons with a search" do
    visit '/t/category/super-clothing?keywords=shirt'
    expect(page).to have_content("Superman T-Shirt")
    expect(page).not_to have_selector("div[data-hook='taxon_children']")
  end

  describe 'meta tags and title' do
    it 'displays metas' do
      t_shirts.update metas
      visit '/t/category/super-clothing/t-shirts'
      expect(page).to have_meta(:description, 'Brand new Ruby on Rails TShirts')
      expect(page).to have_meta(:keywords, 'ror, tshirt, ruby')
    end

    it 'display title if set' do
      t_shirts.update metas
      visit '/t/category/super-clothing/t-shirts'
      expect(page).to have_title("Ruby On Rails TShirt")
    end

    it 'displays title from taxon root and taxon name' do
      visit '/t/category/super-clothing/t-shirts'
      expect(page).to have_title('Category - T-Shirts - ' + store_name)
    end

    # Regression test for https://github.com/spree/spree/issues/2814
    it "doesn't use meta_title as heading on page" do
      t_shirts.update metas
      visit '/t/category/super-clothing/t-shirts'
      within("h1.products__taxon-title") do
        expect(page).to have_content(t_shirts.name)
      end
    end

    it 'uses taxon name in title when meta_title set to empty string' do
      t_shirts.update meta_title: ''
      visit '/t/category/super-clothing/t-shirts'
      expect(page).to have_title('Category - T-Shirts - ' + store_name)
    end
  end

  context "taxon pages" do
    include SolidusStarterFrontend::System::CheckoutHelpers

    before { setup_custom_products }

    let(:product_names) do
      page.all('ul.products-grid li a').map(&:text).flatten.reject(&:blank?).sort
    end

    before do
      visit products_path
    end

    it "should be able to visit brand Ruby on Rails" do
      within(:css, '.taxonomies') { click_link "Accessories" }

      expect(product_names).to contain_exactly(
        "Solidus Water Bottle",
        "Solidus canvas tote bag",
        "Solidus mug set",
        "Solidus notebook"
      )
    end

    it "should be able to visit category Clothing" do
      click_link "Clothing"

      expect(product_names).to contain_exactly(
        "Solidus cap",
        "Solidus dark tee",
        "Solidus hoodie",
        "Solidus long sleeve tee",
        "Solidus t-shirt",
        "Solidus tote",
        "Solidus winter hat"
      )
    end
  end

  # Regression test for https://github.com/solidusio/solidus/issues/2602
  context "root taxon page" do
    it "shows taxon previews" do
      visit nested_taxons_path(taxonomy.root)

      expect(page).to have_css('ul.products-grid li', count: 2)
      expect(page).to have_content("Superman T-Shirt", count: 2)
    end

    context "with prices in other currency" do
      before { Spree::Price.update_all(currency: "CAD") }

      it "shows no products" do
        visit nested_taxons_path(taxonomy.root)

        expect(page).to have_css('ul.products-grid li', count: 0)
        expect(page).to have_no_content("Superman T-Shirt")
      end
    end
  end

  context 'with more taxons', caching: true do
    let!(:more_clothing) { create(:taxon, name: "More Clothing", parent: taxonomy.root, taxonomy: taxonomy) }

    before do
      visit '/t/category/super-clothing/t-shirts'
    end

    it 'changes the current taxon' do
      expect(page).to have_css(".taxonomies li:first.underline")
      expect(page).to have_no_css('.taxonomies li:last.underline')
      find('.taxonomies a[href*="more-clothing"]').click
      expect(page).to have_no_css('.taxonomies li:first.underline')
      expect(page).to have_css('.taxonomies li:last.underline')
    end
  end
end
