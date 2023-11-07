# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(order:)
    @order = order
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@order.id}"
  end

  def format_address(address)
    return unless address
    safe_join([
      address.name,
      tag.br,
      address.address1,
      tag.br,
      address.address2,
      address.city,
      address.zipcode,
      address.state.name,
      tag.br,
      address.country.name,
      tag.br,
      address.phone,
    ], " ")
  end

  def panel_title_with_more_links(title, links)
    tag.details(
      tag.summary(
        tag.span(
          safe_join([
            title,
            component("ui/button").new(
              icon: "more-line",
              scheme: :ghost,
              tag: :span,
              alt: t("spree.edit"),
              class: "cursor-pointer"
            ).render_in(self),
          ]),
          class: 'flex items-center justify-between text-black',
        )
      ) + tag.div(safe_join(links, " "), class: "body-small absolute border border-gray-100 mt-0.5 right-0 flex min-w-[10rem] flex-col p-2 rounded-sm shadow-lg bg-white z-10"),
      class: 'relative',
    )
  end

  def customer_name(user)
    (
      user.default_user_bill_address ||
      user.default_user_ship_address ||
      user.user_addresses.where(default: true).first ||
      user.user_addresses.first
    )&.address&.name
  end
end
