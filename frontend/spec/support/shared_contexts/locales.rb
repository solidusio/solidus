# frozen_string_literal: true

shared_context 'fr locale' do
  before do
    I18n.backend.store_translations(:fr, spree: {
      i18n: { this_file_language: "Français" },
      cart: 'Panier',
      shopping_cart: 'Panier'
    })
  end

  after do
    I18n.locale = :en # reset locale after each spec.
    I18n.reload!
  end
end
