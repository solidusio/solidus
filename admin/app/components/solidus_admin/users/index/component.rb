# frozen_string_literal: true

class SolidusAdmin::Users::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree.user_class.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.users_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def filters
    [
      {
        presentation: Spree::Role.model_name.human.pluralize,
        attribute: "spree_roles_id",
        predicate: "in",
        options: Spree::Role.pluck(:name, :id)
      }
    ]
  end

  def scopes
    [
      { name: :customers, label: t('.scopes.customers'), default: true },
      { name: :admin, label: t('.scopes.admin') },
      { name: :with_orders, label: t('.scopes.with_orders') },
      { name: :without_orders, label: t('.scopes.without_orders') },
      { name: :all, label: t('.scopes.all') },
    ]
  end

  def columns
    [
      {
        header: :email,
        data: :email,
      },
      {
        header: :roles,
        data: ->(user) do
          roles = user.spree_roles.presence || [Spree::Role.new(name: 'customer')]
          safe_join(roles.map {
            color =
              case _1.name
              when 'admin' then :blue
              when 'customer' then :green
              else :graphite_light
              end
            render component('ui/badge').new(name: _1.name, color: color)
          })
        end,
      },
      {
        header: :order_count,
        data: ->(user) { user.order_count },
      },
      {
        header: :lifetime_value,
        data: -> { _1.display_lifetime_value.to_html },
      },
      {
        header: :created_at,
        data: ->(user) { l(user.created_at.to_date, format: :long) },
      },
    ]
  end
end
