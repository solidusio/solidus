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

  def currency_select_options
    options_from_collection_for_select(Spree::Config.available_currencies, :iso_code, :iso_code, Spree::Config.currency)
  end

  def store_credit_categories_select_options
    # Placeholder + Store Credit Categories
    "<option value>#{t(".choose_category")}</option>" + options_from_collection_for_select(@store_credit_categories, :id, :name)
  end
end
