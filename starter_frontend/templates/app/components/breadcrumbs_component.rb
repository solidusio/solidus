# frozen_string_literal: true

class BreadcrumbsComponent < ViewComponent::Base
  attr_reader :taxon, :item_classes, :separator, :separator_classes, :container_classes, :wrapper_classes, :order

  def initialize(
    taxon:,
    order:,
    item_classes: nil,
    separator: "/",
    separator_classes: nil,
    container_classes: "flex",
    wrapper_classes: nil
  )
    @taxon = taxon
    @item_classes = item_classes
    @separator = raw(separator)
    @separator_classes = separator_classes
    @container_classes = container_classes
    @wrapper_classes = wrapper_classes
    @order = order
  end

  def call
    return if current_page?("/")

    content_tag(:div, class: wrapper_classes) do
      content_tag(:nav) do
        content_tag(:ol, class: container_classes, itemscope: "", itemtype: "https://schema.org/BreadcrumbList") do
          raw(items.map(&:mb_chars).join)
        end
      end
    end
  end

  private

  def items
    crumbs.map.with_index do |crumb, index|
      content_tag(:li, itemprop: "itemListElement", itemscope: "", itemtype: "https://schema.org/ListItem") do
        item_link(crumb, index) + (crumb == crumbs.last ? "" : separator_item)
      end
    end
  end

  def separator_item
    content_tag(:span, separator, class: separator_classes)
  end

  def item_link(crumb, index)
    link_to(crumb[:url], itemprop: "item", class: item_classes) do
      content_tag(:span, crumb[:name], itemprop: "name") + meta_tag(index)
    end
  end

  def meta_tag(index)
    tag("meta", { itemprop: "position", content: (index + 1).to_s }, false, false)
  end

  def crumbs
    @crumbs ||= generate_crumbs
  end

  def generate_crumbs
    crumbs = [{ name: t("spree.home"), url: helpers.root_path }]
    append_dynamic_crumbs(crumbs)
    add_taxon_crumbs(crumbs) if taxon
    add_product_crumb(crumbs) if product_page?
    crumbs
  end

  def append_dynamic_crumbs(crumbs)
    action_crumbs = controller_action_map.dig(request.params[:controller], request.params[:action])
    crumbs.concat(action_crumbs) if action_crumbs
    add_order_crumb(crumbs) if order_page?
  end

  # Defines dynamic breadcrumb mappings based on controller and action.
  # Users can extend this hash to add breadcrumbs for additional pages.
  def controller_action_map
    {
      "users" => {
        "show" => [{ name: t("spree.account"), url: helpers.account_path }],
        "edit" => [
          { name: t("spree.account"), url: helpers.account_path },
          { name: t("spree.actions.edit"), url: helpers.edit_account_path }
        ]
      },
      "carts" => {
        "show" => [{ name: t("spree.cart"), url: helpers.cart_path }]
      },
      "user_sessions" => {
        "new" => [{ name: t("spree.login"), url: helpers.login_path }]
      },
      "user_registrations" => {
        "new" => [{ name: t("spree.sign_up"), url: helpers.signup_path }]
      },
      "user_passwords" => {
        "new" => [{ name: t("spree.forgot_password"), url: helpers.recover_password_path }]
      },
      "products" => {
        "index" => [{ name: t("spree.products"), url: helpers.products_path }]
      },
      "checkouts" => {
        "edit" => [{ name: t("spree.checkout"), url: checkout_state_path(request.params[:action]) }]
      }
    }
  end

  # Adds the taxon and its ancestors to the breadcrumbs array.
  def add_taxon_crumbs(crumbs)
    add_product_crumb(crumbs)
    crumbs.concat(taxon.ancestors.map { |ancestor| { name: ancestor.name, url: helpers.nested_taxons_path(ancestor.permalink) } })
    crumbs << { name: taxon.name, url: helpers.nested_taxons_path(taxon.permalink) }
  end

  # Adds order and order number to breadcrumbs on the order show page.
  def add_order_crumb(crumbs)
    return unless order

    crumbs << { name: t("spree.orders"), url: helpers.account_path }
    crumbs << { name: order.number, url: helpers.order_path(order) }
  end

  # Adds a "Products" breadcrumb if it doesn’t already exist in the array.
  def add_product_crumb(crumbs)
    return if crumbs.any? { |crumb| crumb[:name] == t("spree.products") }

    crumbs << { name: t("spree.products"), url: helpers.products_path }
  end

  def order_page?
    request.params["controller"] == "orders" && request.params["action"] == "show"
  end

  def product_page?
    request.params["controller"] == "products" && request.params["action"] == "show"
  end
end
