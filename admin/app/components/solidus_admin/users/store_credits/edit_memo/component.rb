# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::EditMemo::Component < SolidusAdmin::BaseComponent
  def initialize(user:, store_credit:, events:)
    @user = user
    @store_credit = store_credit
    @store_credit_events = events
  end

  def form_id
    dom_id(@store_credit, "#{stimulus_id}_edit_memo_form")
  end
end
