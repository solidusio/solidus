# frozen_string_literal: true

RSpec.shared_context 'fr locale' do
  before do
    I18n.available_locales = [:en, :fr]
    I18n.backend.store_translations(:fr, spree: {
      i18n: { this_file_language: "Français" },
      cart: 'Panier',
      shopping_cart: 'Panier',
      locale_changed: 'Paramètres régionaux changés',
      your_cart_is_empty: 'Votre panier est vide'
    })
  end

  after do
    I18n.available_locales = [:en]
    I18n.locale = :en # reset locale after each spec.
    I18n.reload!
  end
end
