# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::New::Component < SolidusAdmin::Resources::New::Component
  def initialize(user:, store_credit:, categories:)
    @user = user
    super(store_credit)
    @store_credit_categories = categories
  end

  def form_url
    solidus_admin.user_store_credits_path(@user, **search_filter_params)
  end
end
