# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Template rendering', type: :system do
  after do
    Capybara.ignore_hidden_elements = true
  end

  let!(:taxon) {
    taxonomy = create :taxonomy, name: "Solidus Brand"
    create :taxon, name: "Accessories", taxonomy: taxonomy, parent: taxonomy.root
  }

  before do
    Capybara.ignore_hidden_elements = false

    Spree::Store.create!(
      code: 'spree',
      name: 'My Spree Store',
      url: 'spreestore.example.com',
      mail_from_address: 'test@example.com',
      default: true
    )
  end

  it 'layout should have canonical tag referencing site url' do
    visit root_path

    expect(find('link[rel=canonical]')[:href]).to eql('http://spreestore.example.com/')
  end

  it "renders a canonical tag for products index page with keywords query string" do
    create(:product_in_stock, name: 'Solidus Mug', price: 10.00)

    visit products_path(keywords: 'solidus')

    expect(page).to have_content('Solidus Mug')

    expect(
      find('link[rel=canonical]')[:href]
    ).to eql('http://spreestore.example.com/products/?keywords=solidus')
  end

  it "renders a canonical tag for the products index with a taxon query string" do
    create(:product_in_stock, name: 'Solidus Mug', taxons: [taxon])

    visit products_path(keywords: 'solidus', taxon: taxon.id)

    expect(page).to have_content('Solidus Mug')

    expect(
      find('link[rel=canonical]')[:href]
    ).to eql("http://spreestore.example.com/products/?keywords=solidus&taxon=#{taxon.id}")
  end

  it "renders a canonical tag for taxon pages with a search filter query string" do
    create(:product_in_stock, name: 'Solidus Mug', taxons: [taxon])

    visit nested_taxons_path(taxon)

    within "#sidebar_products_search" do
      check "Under $10.00"
      click_on "Search"
    end
    expect(page).to have_content "No products found"

    expect(
      URI::decode_uri_component find('link[rel=canonical]')[:href]
    ).to eql(
      "http://spreestore.example.com/t/solidus-brand/accessories?search[price_range_any][]=Under+$10.00"
    )
  end

  it "renders a canonical tag for taxon pages with multiple pages of search results" do
    create(:product_in_stock, name: 'Solidus Mug 1', taxons: [taxon])
    create(:product_in_stock, name: 'Solidus Mug 2', taxons: [taxon])

    visit nested_taxons_path(taxon, per_page: 1, page: 2)


    expect(
      find('link[rel=canonical]')[:href]
    ).to eql("http://spreestore.example.com/t/solidus-brand/accessories?page=2")
  end
end
