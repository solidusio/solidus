# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::Component < SolidusAdmin::UI::Pages::Index::Component
  include SolidusAdmin::LastLoginHelper

  def model_class
    binding.pry
    Spree::StoreCredit
  end

  def page_header
    page_header_back(solidus_admin.users_path)
  end

  #
  # def page_header_back
  #   solidus_admin.users_path
  # end

  # def page_header_title
  #   t(".title", email: @user.email)
  # end


  #
  # <%= page_header do %>
  #   <%= page_header_back(solidus_admin.users_path) %>
  # <%= page_header_title(t(".title", email: @user.email)) %>
  #
  #   <%= page_header_actions do %>
  #     <%= render component("ui/button").new(tag: :a, text: t(".create_order_for_user"), href: spree.new_admin_order_path(user_id: @user.id)) %>
  # <% end %>
  # <% end %>
  #
  # def search_url
  #   solidus_admin.store_credits_path
  # end

  # def search_key
  #   :name_or_code_cont
  # end

  # def page_actions
  #   render component("ui/button").new(
  #     tag: :a,
  #     text: t('.add'),
  #     href: solidus_admin.user_path(@user), data: { turbo_frame: :new_store_credit_modal },
  #     icon: "add-line",
  #     class: "align-self-end w-full",
  #   )
  # end

  def turbo_frames
    %w[
      new_store_credit_modal
      edit_store_credit_modal
    ]
  end

  def row_url(store_credit)
    # solidus_admin.user_path(@user)
    "/"
    # spree.edit_admin_store_credit_path(store_credit, _turbo_frame: :edit_store_credit_modal)
  end

  # def batch_actions
  #   [
  #     {
  #       label: t('.batch_actions.invalidate'),
  #       action: spree.invalidate_admin_user_store_credit(user_id: @user, id: 1),
  #       method: :put,
  #       icon: 'delete-bin-7-line',
  #       require_confirmation: true,
  #     },
  #   ]
  # end

  def columns
    [
      {
        header: :credited,
        data: ->(store_credit) do
          store_credit.display_amount.to_html
        end
      },
      {
        header: :used,
        data: ->(store_credit) do
          store_credit.display_amount_used.to_html
        end
      },
      {
        header: :authorized,
        data: ->(store_credit) do
          store_credit.display_amount_authorized.to_html
        end
      },
      {
        header: :type,
        data: ->(store_credit) do
          component('ui/badge').new(name: store_credit.credit_type.name, color: :blue)
        end
      },
      {
        header: :created_by,
        data: ->(store_credit) do
          store_credit.created_by_email
        end
      },
      {
        header: :issued_on,
        data: ->(store_credit) do
          I18n.l(store_credit.created_at.to_date)
        end
      },
      {
        header: :invalidated,
        data: ->(store_credit) do
          store_credit.invalidated? ? component('ui/badge').yes : component('ui/badge').no
        end
      },
    ]
  end
end
