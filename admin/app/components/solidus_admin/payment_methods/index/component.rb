# frozen_string_literal: true

class SolidusAdmin::PaymentMethods::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::PaymentMethod
  end

  def search_key
    :name_or_description_cont
  end

  def search_url
    solidus_admin.payment_methods_path
  end

  def edit_path(payment_method)
    solidus_admin.edit_payment_method_path(payment_method)
  end

  def sortable_options
    {
      url: ->(payment_method) { solidus_admin.move_payment_method_path(payment_method) },
      param: 'position',
    }
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: solidus_admin.new_payment_method_path,
      icon: "add-line",
    )
  end

  def batch_actions
    [
      {
        label: t('.batch_actions.delete'),
        action: solidus_admin.payment_methods_path,
        method: :delete,
        icon: 'delete-bin-7-line',
        require_confirmation: true
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
          link_to payment_method.name, edit_path(payment_method), class: "body-link"
        end
      },
      {
        header: :type,
        data: ->(payment_method) do
          link_to payment_method.model_name.human, edit_path(payment_method), class: "body-link"
        end
      },
      {
        header: :available_to_users,
        data: ->(payment_method) do
          if payment_method.available_to_users?
            component('ui/badge').yes
          else
            component('ui/badge').no
          end
        end
      },
      {
        header: :available_to_admin,
        data: ->(payment_method) do
          if payment_method.available_to_admin?
            component('ui/badge').yes
          else
            component('ui/badge').no
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
