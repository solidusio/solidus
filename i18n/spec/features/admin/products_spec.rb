RSpec.feature "Products", :js do
  stub_authorization!
  given!(:product) { create(:product) }

  # Regression Spec: https://github.com/spree/spree_i18n/issues/386
  context "cloning" do
    scenario "doesnt blow up" do
      visit spree.admin_products_path
      click_icon :copy

      expect(page).to have_text_like 'successfully cloned'
    end
  end
end
