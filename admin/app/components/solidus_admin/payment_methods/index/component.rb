# frozen_string_literal: true

class SolidusAdmin::PaymentMethods::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(payment_methods:)
    @payment_methods = payment_methods
  end

  def title
    Spree::PaymentMethod.model_name.human.pluralize
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.payment_methods_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def scopes
    [
      { name: :all, label: t('.scopes.all'), default: true },
      { name: :active, label: t('.scopes.active') },
      { name: :inactive, label: t('.scopes.inactive') },
      { name: :storefront, label: t('.scopes.storefront') },
      { name: :admin, label: t('.scopes.admin') },
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(payment_method) do
          content_tag :div, payment_method.name
        end
      },
      {
        header: :type,
        data: ->(payment_method) do
          content_tag :div, payment_method.model_name.human
        end
      },
      {
        header: :available_to_users,
        data: ->(payment_method) do
          if payment_method.available_to_users?
            component('ui/badge').new(name: t('.yes'), color: :green)
          else
            component('ui/badge').new(name: t('.no'), color: :graphite_light)
          end
        end
      },
      {
        header: :available_to_admin,
        data: ->(payment_method) do
          if payment_method.available_to_admin?
            component('ui/badge').new(name: t('.yes'), color: :green)
          else
            component('ui/badge').new(name: t('.no'), color: :graphite_light)
          end
        end
      },
      {
        header: :status,
        data: ->(payment_method) do
          if payment_method.active?
            render component('ui/badge').new(name: t('.status.active'), color: :green)
          else
            render component('ui/badge').new(name: t('.status.inactive'), color: :graphite_light)
          end
        end
      },
    ]
  end
end
