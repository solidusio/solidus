# frozen_string_literal: true

class SolidusAdmin::ShippingMethods::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::ShippingMethod.model_name.human.pluralize
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
        action: solidus_admin.shipping_methods_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
    ]
  end

  def filters
    []
  end

  def scopes
    []
  end

  def columns
    [
      {
        header: :name,
        data: -> { [_1.admin_name.presence, _1.name].compact.join(' / ') },
      },
      {
        header: :zone,
        data: -> { _1.zones.pluck(:name).to_sentence },
      },
      {
        header: :calculator,
        data: -> { _1.calculator&.description },
      },
      {
        header: :available_to_users,
        data: -> { _1.available_to_users? ? component('ui/badge').yes : component('ui/badge').no },
      },
    ]
  end
end
