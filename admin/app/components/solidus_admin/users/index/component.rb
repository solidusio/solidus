# frozen_string_literal: true

class SolidusAdmin::Users::Index::Component < SolidusAdmin::UsersAndRoles::Component
  include SolidusAdmin::LastLoginHelper

  def model_class
    Spree.user_class
  end

  def search_key
    :email_cont
  end

  def search_url
    solidus_admin.users_path
  end

  def row_url(user)
    solidus_admin.edit_user_path(user)
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_user_path,
      icon: "add-line",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.users_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def scopes
    [
      { name: :all, label: t('.scopes.all'), default: true },
      { name: :customers, label: t('.scopes.customers') },
      { name: :admin, label: t('.scopes.admin') },
      { name: :with_orders, label: t('.scopes.with_orders') },
      { name: :without_orders, label: t('.scopes.without_orders') },
    ]
  end

  def filters
    [
      {
        label: Spree::Role.model_name.human.pluralize,
        attribute: "spree_roles_id",
        predicate: "in",
        options: Spree::Role.pluck(:name, :id)
      }
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
            render component('ui/badge').new(name: _1.name, color:)
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
        header: :last_active,
        data: ->(user) { last_login(user) },
      },
    ]
  end
end
