# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::EditAmount::Component < SolidusAdmin::Resources::Edit::Component
  def initialize(user:, store_credit:, reasons:)
    @user = user
    super(store_credit)
    @store_credit_reasons = reasons
  end

  def form_id
    dom_id(@store_credit, "#{stimulus_id}_edit_amount_form")
  end

  def form_url
    solidus_admin.update_amount_user_store_credit_path(@user, @store_credit, **search_filter_params)
  end
end
