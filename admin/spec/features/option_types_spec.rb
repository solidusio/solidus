# frozen_string_literal: true

require 'spec_helper'
require "solidus_admin/testing_support/shared_examples/moveable"

describe "Option Types", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists option types and allows deleting them" do
    create(:option_type, name: "color", presentation: "Color")
    create(:option_type, name: "size", presentation: "Size")

    visit "/admin/option_types"
    expect(page).to have_content("color")
    expect(page).to have_content("size")

    expect(page).to be_axe_clean

    select_row("color")
    accept_confirm("Are you sure you want to delete 1 option type?") { click_on "Delete" }
    expect(page).to have_content("Option types were successfully removed.")
    expect(page).not_to have_content("color")
    expect(Spree::OptionType.count).to eq(1)
  end

  it "allows to create option types/values" do
    visit "/admin/option_types"
    click_on "Add new"

    fill_in "Name", with: "clothing-color"
    fill_in "Presentation", with: "Color"
    click_on "Add Option Type"

    expect(page).to have_current_path(/\/admin\/option_types\/\d+\/edit/)
    click_on "Add new"

    within("dialog") do
      fill_in "Name", with: "blue"
      fill_in "Presentation", with: "Blue"
      click_on "Add Option Value"
    end

    expect(page).to have_content("Option value was successfully created.")
  end

  it "allows to update option types" do
    create(:option_type, name: "color", presentation: "Color")
    visit "/admin/option_types"
    click_on "Color"

    fill_in "Name", with: "clt-colour"
    fill_in "Presentation", with: "Colour"
    within("header") { click_on "Save" }

    expect(page).to have_current_path("/admin/option_types")
    expect(page).to have_content("Option type was successfully updated.")
    expect(page).to have_content("clt-colour")
    expect(page).to have_content("Colour")
    expect(page).not_to have_content("color")
    expect(page).not_to have_content("Color")
  end

  it "allows to edit and destroy option values" do
    create(:option_type, name: "color", presentation: "Color").tap do |option_type|
      option_type.option_values = [
        create(:option_value, name: "blue", presentation: "Blue"),
        create(:option_value, name: "green", presentation: "Green"),
      ]
    end

    visit "/admin/option_types"
    click_on "Color"

    click_on "Blue"
    within("dialog") do
      fill_in "Name", with: "sky-blue"
      fill_in "Presentation", with: "Sky Blue"
    end

    click_on "Update Option Value"
    expect(page).to have_content("Option value was successfully updated.")
    expect(find("table")).to have_content("sky-blue")
    expect(find("table")).to have_content("Sky Blue")

    select_row("green")
    accept_confirm("Are you sure you want to delete 1 option value?") { click_on "Delete" }
    expect(page).to have_content("Option values were successfully removed.")
    expect(page).not_to have_content("green")
  end

  it "preserves user input" do
    create(:option_type, name: "color", presentation: "Color")

    visit "/admin/option_types"
    click_on "Color"

    fill_in "Name", with: "clothing-colour"
    fill_in "Presentation", with: "Colour"

    click_on "Add new"
    within("dialog") do
      fill_in "Name", with: "blue"
      fill_in "Presentation", with: "Blue"
      click_on "Add Option Value"
    end

    expect(find_field("Name").value).to eq("clothing-colour")
    expect(find_field("Presentation").value).to eq("Colour")
  end

  context "with invalid attributes" do
    context "on option type create" do
      it "shows errors" do
        visit "/admin/option_types"
        click_on "Add new"
        click_on "Add Option Type"
        expect(page).to have_content("can't be blank")
      end
    end

    context "on option type update" do
      it "shows errors" do
        option_type = create(:option_type, name: "color", presentation: "Color")
        visit "/admin/option_types/#{option_type.id}/edit"
        fill_in "Name", with: ""
        within("header") { click_on "Save" }
        expect(page).to have_content("can't be blank")
      end
    end

    context "on option value create" do
      it "shows errors" do
        option_type = create(:option_type, name: "color", presentation: "Color")
        visit "/admin/option_types/#{option_type.id}/edit"
        click_on "Add new"
        click_on "Add Option Value"
        expect(page).to have_content("can't be blank")
      end
    end

    context "on option value update" do
      it "shows errors" do
        option_type = create(:option_type, name: "color", presentation: "Color").tap do |option_type|
          option_type.option_values = [create(:option_value, name: "blue")]
        end

        visit "/admin/option_types/#{option_type.id}/edit"
        click_on "blue"
        within("dialog") { fill_in "Name", with: "" }
        click_on "Update Option Value"
        expect(page).to have_content("can't be blank")
      end
    end
  end

  describe "sorting option types" do
    include_examples "features: sortable" do
      let(:factory) { :option_type }
      let(:displayed_attribute) { :name }
      let(:path) { solidus_admin.option_types_path }
    end
  end

  describe "sorting option values" do
    include_examples "features: sortable" do
      let!(:option_type) { create(:option_type) }
      let(:factory) { :option_value }
      let(:factory_attrs) { { option_type: } }
      let(:displayed_attribute) { :name }
      let(:path) { solidus_admin.edit_option_type_path(option_type) }
    end
  end
end
