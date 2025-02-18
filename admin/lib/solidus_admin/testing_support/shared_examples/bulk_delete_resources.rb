# frozen_string_literal: true

RSpec.shared_examples_for 'feature: bulk delete resources' do
  it 'allows to bulk delete resources' do
    create(resource_factory, name: 'Bulk delete item 1')
    create(resource_factory, name: 'Bulk delete item 2')

    visit index_path
    expect(page).to have_content('Bulk delete item 1')
    expect(page).to have_content('Bulk delete item 2')

    select_row('Bulk delete item 1')
    select_row('Bulk delete item 2')
    click_on 'Delete'

    expect(page).to have_content('were successfully removed.')
    expect(page).not_to have_content('Bulk delete item 1')
    expect(page).not_to have_content('Bulk delete item 2')
  end
end
