# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(user:, store_credits:)
    @user = user
    @store_credits = store_credits
  end

  def model_class
    Spree::StoreCredit
  end

  def tabs
    [
      {
        text: t('.account'),
        href: solidus_admin.user_path(@user),
        current: false,
      },
      {
        text: t('.addresses'),
        href: solidus_admin.addresses_user_path(@user),
        current: false,
      },
      {
        text: t('.order_history'),
        href: solidus_admin.orders_user_path(@user),
        current: false,
      },
      {
        text: t('.items'),
        href: spree.items_admin_user_path(@user),
        current: false,
      },
      {
        text: t('.store_credit'),
        href: solidus_admin.store_credits_user_path(@user),
        current: true,
      },
    ]
  end

  def rows
    @store_credits
  end

  def row_url(store_credit)
    spree.admin_user_store_credit_path(@user, store_credit)
  end

  def columns
    [
      {
        header: :credited,
        col: { class: "w-[12%]" },
        data: ->(store_credit) do
          content_tag :div, store_credit.display_amount.to_html, class: "text-sm"
        end
      },
      {
        header: :authorized,
        col: { class: "w-[13%]" },
        data: ->(store_credit) do
          content_tag :div, store_credit.display_amount_authorized.to_html, class: "text-sm"
        end
      },
      {
        header: :used,
        col: { class: "w-[9%]" },
        data: ->(store_credit) do
          content_tag :div, store_credit.display_amount_used.to_html, class: "text-sm"
        end
      },
      {
        header: :type,
        col: { class: "w-[13%]" },
        data: ->(store_credit) do
          component('ui/badge').new(name: store_credit.credit_type.name, color: :blue)
        end
      },
      {
        header: :created_by,
        col: { class: "w-[22%]" },
        data: ->(store_credit) do
          content_tag :div, store_credit.created_by_email, class: "font-semibold text-sm"
        end
      },
      {
        header: :issued_on,
        col: { class: "w-[16%]" },
        data: ->(store_credit) do
          I18n.l(store_credit.created_at.to_date)
        end
      },
      {
        header: :invalidated,
        col: { class: "w-[15%]" },
        data: ->(store_credit) do
          store_credit.invalidated? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
