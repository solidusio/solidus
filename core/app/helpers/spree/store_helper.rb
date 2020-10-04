# frozen_string_literal: true

module Spree
  # Methods added to this helper will be available to all templates in the
  # frontend.
  module StoreHelper
    # @return [Boolean] true when it is appropriate to show the store menu
    def store_menu?
      %w{thank_you}.exclude? params[:action]
    end

    def cache_key_for_taxons
      Spree::Deprecation.warn <<-WARN.strip_heredoc
        cache_key_for_taxons is deprecated. Rails >= 5 has built-in support for collection cache keys.
        Instead in your view use:
        cache [I18n.locale, @taxons] do
      WARN
      max_updated_at = @taxons.maximum(:updated_at).to_i
      parts = [@taxon.try(:id), max_updated_at].compact.join("-")
      "#{I18n.locale}/taxons/#{parts}"
    end
  end
end
