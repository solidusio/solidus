# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'searching products', :js, type: :system do
  include SolidusStarterFrontend::System::CheckoutHelpers

  before do
    setup_custom_products
    visit root_path
  end

  it 'shows a blank slate for empty searches' do
    fill_search_input_with 'this-product-does-not-exist'
    click_button 'Search'

    expect(page).to have_content('No results')
  end

  it 'shows autocomplete suggestions' do
    fill_search_input_with 'Solidus'
    expect(page.all('[data-search-target="result"]').size).to eq(6)
  end

  it 'automatically selects the first suggestion' do
    fill_search_input_with 'Solidus'
    expect(page.all('[data-search-target="result"]')[0][:class]).to include('text-primary')
  end

  it 'scrolls up and down through suggestions using up/down arrow keys' do
    fill_search_input_with 'Solidus'
    wait_for_autocomplete

    find('input[name=keywords]').native.send_keys(:down)
    expect(page.all('[data-search-target="result"]')[1][:class]).to include('text-primary')

    find('input[name=keywords]').native.send_keys(:up)
    expect(page.all('[data-search-target="result"]')[0][:class]).to include('text-primary')
  end

  it 'allows mouse click on results' do
    fill_search_input_with 'Solidus'
    wait_for_autocomplete

    find_all('[data-search-target="result"] a')[0].click
    expect(page).to have_current_path('/products/solidus-hoodie')
  end

  it 'clicks on a suggestion pressing enter' do
    fill_search_input_with 'Solidus'
    wait_for_autocomplete
    find('input[name=keywords]').native.send_keys(:enter)

    expect(page).to have_current_path('/products/solidus-hoodie')
  end

  it 'closes autocomplete suggestions pressing esc key' do
    fill_search_input_with 'Solidus'
    wait_for_autocomplete
    find('input[name=keywords]').native.send_keys(:escape)

    expect(page).not_to have_selector('[data-search-target="result"]', visible: true)
  end

  it 'closes autocomplete suggestions clicking outside the search input' do
    fill_search_input_with 'Solidus'
    wait_for_autocomplete
    find('input[name=keywords]').native.send_keys(:escape)

    find('[data-controller="top-bar"]').click
    expect(page).not_to have_selector('[data-search-target="result"]', visible: true)
  end

  def wait_for_autocomplete
    expect(page).to have_selector('[data-search-target="result"]', visible: true)
  end

  def fill_search_input_with(text)
    find('.search-bar__button').click
    fill_in 'keywords', with: text
  end
end
