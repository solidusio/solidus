# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::EditMemo::Component < SolidusAdmin::Resources::Edit::Component
  def initialize(user:, store_credit:)
    @user = user
    super(store_credit)
  end

  def form_id
    dom_id(@store_credit, "#{stimulus_id}_edit_memo_form")
  end

  def form_url
    solidus_admin.update_memo_user_store_credit_path(@user, @store_credit, **search_filter_params)
  end
end
