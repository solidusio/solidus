# frozen_string_literal: true
require 'solidus_admin/testing_support/shared_examples/bulk_delete_resources'

RSpec.shared_examples_for 'promotion categories features' do
  before { sign_in create(:admin_user, email: "admin@example.com") }

  it "lists promotion categories" do
    create(factory_name, name: "test1", code: "code1")
    create(factory_name, name: "test2", code: "code2")

    visit index_path
    expect(page).to have_content("test1")
    expect(page).to have_content("test2")

    expect(page).to be_axe_clean
  end

  it 'allows to create new promo category' do
    visit index_path

    click_on "Add new"
    expect(turbo_frame_modal).to have_content("New Promotion Category")

    fill_in "Code", with: "ste.1"
    click_on "Add Promotion Category"

    expect(turbo_frame_modal).to have_content("can't be blank")

    fill_in "Name", with: "Soon to expire"
    click_on "Add Promotion Category"

    expect(page).to have_content("Promotion category was successfully created.")
    expect(page).to have_content("Soon to expire")
    expect(page).to have_content("ste.1")
    expect(model_class.count).to eq(1)
  end

  it 'allows to update promo category' do
    create(factory_name, name: "Soon to expire", code: "ste.1")

    visit index_path

    click_on "Soon to expire"
    expect(turbo_frame_modal).to have_content("Edit Promotion Category")

    fill_in "Name", with: "Expired"
    fill_in "Code", with: "exp.2"
    click_on "Update Promotion Category"

    expect(page).to have_content("Promotion category was successfully updated.")
    expect(page).to have_content("Expired")
    expect(page).to have_content("exp.2")
  end

  it 'allows to delete promo category' do
    create(factory_name, name: "Soon to expire", code: "ste.1")
    create(factory_name, name: "Expired", code: "exp.2")

    visit index_path

    select_row("Expired")
    click_on "Delete"
    expect(page).to have_content("Promotion categories were successfully removed.")
    expect(page).not_to have_content("Expired")
    expect(model_class.count).to eq(1)
  end

  include_examples 'feature: bulk delete resources' do
    let(:resource_factory) { factory_name }
  end
end
