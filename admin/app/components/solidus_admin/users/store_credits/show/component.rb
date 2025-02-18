# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::Show::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers
  include Spree::Admin::StoreCreditEventsHelper

  def initialize(user:, store_credit:, events:)
    @user = user
    @store_credit = store_credit
    @events = events
  end

  def model_class
    Spree::StoreCredit
  end

  def event_model_class
    Spree::StoreCreditEvent
  end

  def tabs
    [
      {
        text: t(".account"),
        href: solidus_admin.user_path(@user),
        current: false
      },
      {
        text: t(".addresses"),
        href: solidus_admin.addresses_user_path(@user),
        current: false
      },
      {
        text: t(".order_history"),
        href: solidus_admin.orders_user_path(@user),
        current: false
      },
      {
        text: t(".items"),
        href: spree.items_admin_user_path(@user),
        current: false
      },
      {
        text: t(".store_credit"),
        href: solidus_admin.user_store_credits_path(@user),
        current: true
      }
    ]
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@store_credit.id}"
  end

  def edit_validity_url
    solidus_admin.edit_validity_user_store_credit_path(@user, @store_credit, **search_filter_params)
  end

  def edit_memo_url
    solidus_admin.edit_memo_user_store_credit_path(@user, @store_credit, **search_filter_params)
  end

  def edit_amount_url
    solidus_admin.edit_amount_user_store_credit_path(@user, @store_credit, **search_filter_params)
  end

  def columns
    [
      {
        header: :date,
        col: {class: "w-[15%]"},
        data: ->(event) do
          content_tag :span, I18n.l(event.created_at, format: :short), class: "text-sm"
        end
      },
      {
        header: :action,
        col: {class: "w-[10%]"},
        data: ->(event) do
          content_tag :span, store_credit_event_admin_action_name(event), class: "text-sm"
        end
      },
      {
        header: :credited,
        col: {class: "w-[10%]"},
        data: ->(event) do
          content_tag :span, event.display_amount, class: "text-sm"
        end
      },
      {
        header: :created_by,
        col: {class: "w-[20%]"},
        data: ->(event) do
          content_tag :span, store_credit_event_originator_link(event), class: "body-link text-sm"
        end
      },
      {
        header: :total_amount,
        col: {class: "w-[10%]"},
        data: ->(event) do
          content_tag :span, event.display_user_total_amount, class: "text-sm"
        end
      },
      {
        header: :total_unused,
        col: {class: "w-[10%]"},
        data: ->(event) do
          content_tag :span, event.display_remaining_amount, class: "text-sm"
        end
      },
      {
        header: :reason_for_updating,
        col: {class: "w-[25%]"},
        data: ->(event) do
          content_tag :span, event.store_credit_reason&.name, class: "text-sm"
        end
      }
    ]
  end
end
