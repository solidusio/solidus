# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::New::Component < SolidusAdmin::BaseComponent
  def initialize(user:, store_credit:, categories:)
    @user = user
    @store_credit = store_credit
    @store_credit_categories = categories
    @store_credits = Spree::StoreCredit.where(user_id: @user.id).order(id: :desc)
  end

  def form_id
    dom_id(@store_credit, "#{stimulus_id}_new_form")
  end

  def currency_select_options
    options_from_collection_for_select(Spree::Config.available_currencies, :iso_code, :iso_code, Spree::Config.currency)
  end

  def store_credit_categories_select_options
    # Placeholder + Store Credit Categories
    "<option value>#{t('.choose_category')}</option>" + options_from_collection_for_select(@store_credit_categories, :id, :name)
  end
end
