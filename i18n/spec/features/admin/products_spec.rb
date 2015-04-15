RSpec.feature "Products", :js do
  stub_authorization!
  given!(:product) { create(:product) }
  given!(:store) { create(:store) }

  # Regression Spec: https://github.com/spree/spree_i18n/issues/386
  context "cloning" do
    scenario "doesnt blow up" do
      visit spree.admin_products_path
      click_icon :clone

      expect(page).to have_text_like 'has been cloned'
    end
  end
end
