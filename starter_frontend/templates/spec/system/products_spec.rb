# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Visiting Products', type: :system do
  include  SolidusStarterFrontend::System::CheckoutHelpers

  before { setup_custom_products }
  let(:store_name) { Spree::Store.first.try(:name) }

  before(:each) do
    visit products_path
  end

  it 'redirects to cart after adding a product to it' do
    click_link 'Solidus tote'
    expect(page).to have_content('$19.99')

    click_button 'add-to-cart-button'
    expect(page).to have_content('Shopping Cart')
  end

  context 'when generating product links' do
    let(:product) { Spree::Product.available.first }

    it 'does not use the *_url helper to generate the product links' do
      visit products_path
      expect(page).not_to have_xpath(".//a[@href='#{product_url(product, host: current_host)}']")
    end

    it 'uses *_path helper to generate the product links' do
     visit products_path
     expect(page).to have_xpath(".//a[@href='#{product_path(product)}']")
    end
  end

  context 'meta tags and title' do
    let(:hoodie) { Spree::Product.find_by(name: 'Solidus hoodie') }
    let(:metas) do
      {
        meta_description: 'Brand new Solidus hoodie',
        meta_title: 'Solidus hoodie Buy High Quality Geek Apparel',
        meta_keywords: 'hoodie, cozy'
      }
    end

    it 'returns the correct title when displaying a single product' do
      click_link hoodie.name
      expect(page).to have_title('Solidus hoodie - ' + store_name)
      within('h1') do
        expect(page).to have_content('Solidus hoodie')
      end
    end

    it 'displays metas' do
      hoodie.update metas
      click_link hoodie.name
      expect(page).to have_meta(:description, 'Brand new Solidus hoodie')
      expect(page).to have_meta(:keywords, 'hoodie, cozy')
    end

    it 'displays title if set' do
      hoodie.update metas
      click_link hoodie.name
      expect(page).to have_title('Solidus hoodie Buy High Quality Geek Apparel')
    end

    it "doesn't use meta_title as heading on page" do
      hoodie.update metas
      click_link hoodie.name
      within('h1') do
        expect(page).to have_content(hoodie.name)
        expect(page).not_to have_content(hoodie.meta_title)
      end
    end

    it 'uses product name in title when meta_title set to empty string' do
      hoodie.update meta_title: ''
      click_link hoodie.name
      expect(page).to have_title('Solidus hoodie - ' + store_name)
    end
  end

  context 'schema.org markup' do
    let(:product) { Spree::Product.available.first }

    it 'has correct schema.org/Offer attributes' do
      expect(page).to have_css("#product_#{product.id} [itemprop='price'][content='19.99']")
      expect(page).to have_css("#product_#{product.id} [itemprop='priceCurrency'][content='USD']")
      click_link product.name
      expect(page).to have_css("[itemprop='price'][content='19.99']")
      expect(page).to have_css("[itemprop='priceCurrency'][content='USD']")
    end
  end

  context 'using Russian Rubles as a currency' do
    before do
      stub_spree_preferences(currency: 'RUB')
    end

    let!(:product) do
      product = Spree::Product.find_by(name: 'Solidus hoodie')
      product.price = 19.99
      product.tap(&:save)
    end

    # Regression tests for https://github.com/spree/spree/issues/2737
    context 'uses руб as the currency symbol' do
      it 'on products page' do
        visit products_path
        within("#product_#{product.id}") do
          within('.price') do
            expect(page).to have_content('19.99 ₽')
          end
        end
      end

      it 'on product page' do
        visit product_path(product)
        within("[data-js='price']") do
          expect(page).to have_content('19.99 ₽')
        end
      end

      it "when on the 'address' state of the cart", js: true do
        visit product_path(product)
        click_button 'Add To Cart'
        checkout_as_guest

        within('#item-total') do
          expect(page).to have_content('19.99 ₽')
        end
      end
    end
  end

  context 'a product with variants' do
    let(:product) { Spree::Product.find_by(name: 'Solidus hoodie') }
    let(:option_value) { create(:option_value) }
    let!(:variant) { product.variants.create!(price: 5.59) }

    before do
      image = File.open(
        File.join(Spree::Core::Engine.root, "lib", "spree", "testing_support", "fixtures", "blank.jpg")
      )
      product.images.create!(attachment: image)
      product.images.create!(attachment: image)

      product.option_types << option_value.option_type
      variant.option_values << option_value
    end

    it 'displays price of first variant listed', js: true do
      click_link product.name

      within("#product-price") do
        expect(page).to have_content variant.price
        expect(page).not_to have_content I18n.t('spree.out_of_stock')
      end
    end

    it "doesn't display out of stock for master product" do
      product.master.stock_items.update_all count_on_hand: 0, backorderable: false

      click_link product.name
      within("[data-js='price']") do
        expect(page).not_to have_content I18n.t('spree.out_of_stock')
      end
    end
  end

  context 'a product with variants, images only for the variants' do
    let(:product) do
      Spree::Product.find_by(name: 'Solidus hoodie')
    end

    before do
      image = File.open(
        File.join(Spree::Core::Engine.root, "lib", "spree", "testing_support", "fixtures", "blank.jpg")
      )
      v1 = product.variants.create!(price: 9.99)
      v2 = product.variants.create!(price: 10.99)
      v1.images.create!(attachment: image)
      v2.images.create!(attachment: image)
    end

    it 'does not display "no image available"' do
      visit products_path
      expect(page).to have_xpath("//img[contains(@src,'blank')]")
    end
  end

  it 'hides products without price' do
    expect(page.all('ul.products-grid li').size).to eq(12)
    stub_spree_preferences(show_products_without_price: false)
    stub_spree_preferences(currency: 'GBP')
    visit products_path
    expect(page.all('ul.products-grid li').size).to eq(0)
  end

  it 'can filter products' do
    visit products_path

    within(:css, '.taxonomies') { click_link 'Accessories' }
    check 'Price_Range__15.00_-__18.00'
    within(:css, '#sidebar_products_search') { click_button 'Search' }

    product_names = page.all('ul.products-grid li a').map(&:text).flatten.reject(&:blank?).sort

    expect(product_names)
      .to eq(['Solidus canvas tote bag'])
  end

  it 'lists products without a price' do
    stub_spree_preferences(currency: 'CAD')
    stub_spree_preferences(show_products_without_price: true)
    visit products_path
    expect(page).to have_content("Solidus hoodie")
  end

  it "does not allow to put a product without a current price in the cart" do
    stub_spree_preferences(currency: 'CAD')
    stub_spree_preferences(show_products_without_price: true)
    click_link "Solidus hoodie"
    expect(page).to have_content 'This product is not available in the selected currency'
    expect(page).not_to have_content 'add-to-cart-button'
  end

  it 'returns the correct title when displaying a single product' do
    product = Spree::Product.find_by(name: 'Solidus hoodie')
    click_link product.name

    within('h1') do
      expect(page).to have_content('Solidus hoodie')
    end
  end
end
