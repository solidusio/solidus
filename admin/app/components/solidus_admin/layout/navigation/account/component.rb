# frozen_string_literal: true

# Account navigation
class SolidusAdmin::Layout::Navigation::Account::Component < SolidusAdmin::BaseComponent
  # @param user_label [String]
  # @param account_path [String]
  # @param logout_path [String]
  # @param logout_method [Symbol]
  def initialize(user_label:, account_path:, logout_path:, logout_method:)
    @user_label = user_label
    @account_path = account_path
    @logout_path = logout_path
    @logout_method = logout_method
  end

  def locale_options_for_select(available_locales)
    available_locales.map do |locale|
      [
        t("spree.i18n.this_file_language", locale: locale, default: locale.to_s, fallback: false),
        locale,
      ]
    end.sort
  end
end
