# frozen_string_literal: true

# Account navigation
class SolidusAdmin::Sidebar::AccountNav::Component < SolidusAdmin::BaseComponent
  # @param user_label [String]
  # @param account_path [String]
  # @param logout_path [String]
  # @param logout_method [Symbol]
  def initialize(user_label: "Alice Doe", account_path: "#", logout_path: "#", logout_method: :delete)
    @user_label = user_label
    @account_path = account_path
    @logout_path = logout_path
    @logout_method = logout_method
  end
end
