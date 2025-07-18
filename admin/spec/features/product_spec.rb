# frozen_string_literal: true

require 'spec_helper'
require "solidus_admin/testing_support/shared_examples/moveable"

describe "Product", type: :feature do
  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?) { true }
    sign_in create(:admin_user, email: 'admin@example.com')
  end

  it "lists products", :js do
    create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99)

    visit "/admin/products/just-a-prod"

    expect(page).to have_content("Just a product")
    expect(page).to have_content("SEO")
    expect(page).to have_content("Media")
    expect(page).to have_content("Pricing")
    expect(page).to have_content("Stock")
    expect(page).to have_content("Shipping")
    expect(page).to have_content("Options")
    expect(page).to have_content("Specifications")
    expect(page).to have_content("Publishing")
    expect(page).to have_content("Product organization")
    expect(page).to be_axe_clean
  end

  it "redirects the edit route to the show path" do
    create(:product, slug: 'just-a-prod')

    visit "/admin/products/just-a-prod/edit"

    expect(page).to have_current_path("/admin/products/just-a-prod")
  end

  it "can update a product", :js do
    create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99)

    visit "/admin/products/just-a-prod"

    fill_in "Name", with: "Just a product (updated)"
    uncheck 'Promotable'
    within('header') { click_button "Save" }

    expect(page).to have_content("Just a product (updated)")
    expect(checkbox("Promotable")).not_to be_checked

    fill_in "Name", with: ""
    within('header') { click_button "Save" }

    expect(page).to have_content("Name can't be blank")
    expect(page).to be_axe_clean
  end

  describe "option types", :js do
    before do
      create(:option_type, name: "clothing-size", presentation: "Size").tap do |option_type|
        option_type.option_values << [
          create(:option_value, name: "S", presentation: "Small"),
          create(:option_value, name: "M", presentation: "Medium")
        ]
      end

      create(:option_type, name: "clothing-color", presentation: "Color").tap do |option_type|
        option_type.option_values << [
          create(:option_value, name: "brown", presentation: "Brown"),
          create(:option_value, name: "red", presentation: "Red")
        ]
      end
    end

    let!(:product) { create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99) }

    it "updates option types" do
      visit "/admin/products/just-a-prod"
      solidus_select(%w[clothing-size:Size clothing-color:Color], from: "Option Types")
      options_panel = panel(title: "Options")
      # for some reason capybara on circle ci does not register a form submit when clicking "Save" within options panel,
      # so we have to resort to Save button in the header
      within("header") { click_on "Save" }

      expect(options_panel).to have_content("clothing-size:Size")
      expect(options_panel).to have_content("S:Small")
      expect(options_panel).to have_content("M:Medium")
      expect(options_panel).to have_content("clothing-color:Color")
      expect(options_panel).to have_content("brown:Brown")
      expect(options_panel).to have_content("red:Red")

      solidus_unselect(%w[clothing-size:Size clothing-color:Color], from: "Option Types")
      within(options_panel) { click_on "Save" }

      expect(options_panel).not_to have_content("clothing-size:Size")
      expect(options_panel).not_to have_content("S:Small")
      expect(options_panel).not_to have_content("M:Medium")
      expect(options_panel).not_to have_content("clothing-color:Color")
      expect(options_panel).not_to have_content("brown:Brown")
      expect(options_panel).not_to have_content("red:Red")
    end

    context "clicking on Edit" do
      xit "leads to option type edit page" do
        option_type = create(:option_type)
        product.option_types << option_type
        visit "/admin/products/just-a-prod"

        within(panel(title: "Options")) { click_on "Edit" }
        expect(page).to have_current_path("/admin/option_types/#{option_type.id}/edit")
      end
    end

    context "clicking on Manage option types" do
      it "leads to option types index page" do
        visit "/admin/products/just-a-prod"

        within(panel(title: "Options")) { click_on "Manage option types" }
        expect(page).to have_current_path("/admin/option_types")
      end
    end

    it_behaves_like "features: sortable" do
      let(:product) { create(:product) }
      let(:factory) { :option_type }
      let(:factory_attrs) { { products: [product] } }
      let(:displayed_attribute) { :name }
      let(:handle) { ".handle" }
      let(:path) { solidus_admin.product_path(product) }
    end
  end

  describe "product organization", :js do
    let(:taxonomy) { create(:taxonomy, name: "Apparel") }
    let(:root_taxon) { taxonomy.root }
    let!(:child_taxon) { create(:taxon, name: "Caps", parent: root_taxon) }
    let!(:product) { create(:product, name: "Just a product", slug: 'just-a-prod', price: 19.99) }

    describe "assigning categories" do
      it "assigns product categories" do
        visit "/admin/products/just-a-prod"
        expect(solidus_select_control("Categories").text).to be_empty

        solidus_select %w[Apparel Caps], from: "Categories"
        within("header") { click_on "Save" }
        expect(page).to have_content("Product was successfully updated.")

        visit "/admin/products/just-a-prod"
        expect(solidus_select_control("Categories")).to have_content("Apparel")
        expect(solidus_select_control("Categories")).to have_content("Caps")
      end

      it "unassigns product categories" do
        product.taxons << root_taxon

        visit "/admin/products/just-a-prod"
        solidus_unselect "Apparel", from: "Categories"
        within("header") { click_on "Save" }
        expect(page).to have_content("Product was successfully updated.")

        visit "/admin/products/just-a-prod"
        expect(solidus_select_control("Categories").text).to be_empty
      end
    end

    context "adding new category" do
      it "creates new category and assigns it to product" do
        visit "/admin/products/just-a-prod"
        click_on "Add new category"
        expect(page).to have_content("New Category")

        within(dialog) do
          fill_in "Name", with: "Jackets"
          solidus_select "Apparel", from: "Parent Category"
          click_on "Add Category"
        end

        expect(page).to have_content("Product category was successfully added.")
        expect(page).not_to have_css("dialog")
        expect(page).not_to have_content("New Category")
        expect(solidus_select_control("Categories")).to have_content("Jackets")
      end

      context "with invalid attributes" do
        context "with blank name" do
          it "shows error" do
            visit "/admin/products/just-a-prod"
            click_on "Add new category"
            within(dialog) { click_on "Add Category" }

            expect(dialog).to have_content("can't be blank")
          end
        end

        context "when taxon with same name already belongs to a parent" do
          it "shows error" do
            visit "/admin/products/just-a-prod"
            click_on "Add new category"
            within(dialog) do
              fill_in "Name", with: child_taxon.name
              solidus_select "Apparel", from: "Parent Category"
              click_on "Add Category"
            end

            expect(dialog).to have_content("must be unique under the same parent Taxon")
          end
        end
      end
    end
  end
end
