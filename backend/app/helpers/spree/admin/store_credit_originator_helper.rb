module Spree::Admin::StoreCreditOriginatorHelper
  mattr_accessor :originator_links

  self.originator_links = {
    Spree::Payment.to_s => {
      new_tab: true,
      href_type: :payment,
      translation_key: 'admin.store_credits.payment_originator'
    },

    Spree::Refund.to_s => {
      new_tab: true,
      href_type: :payments,
      translation_key: 'admin.store_credits.refund_originator'
    }
  }

  def store_credit_originator_link(object)
    return unless object.originator

    add_user_originator_link

    originator = object.originator
    klass = object.originator.class.to_s

    unless originator_links.key?(klass)
      raise "Unexpected originator type #{klass}"
    end

    options = {}
    link_options = originator_links[klass]
    options[:target] = '_blank' if link_options[:new_tab]

    # Although not all href_types are used in originator_links
    # they are necessary because they may be used within extensions
    case link_options[:href_type]
    when :user
      link_to(
        Spree.t(link_options[:translation_key], { email: originator.email }),
        spree.edit_admin_user_path(originator),
        options
      )
    when :line_item
      order = originator.line_item.order
      link_to(
        Spree.t(link_options[:translation_key], { order_number: order.number }),
        spree.edit_admin_order_path(order),
        options
      )
    when :payment
      order = originator.order
      link_to(
        Spree.t(link_options[:translation_key], { order_number: order.number }),
        spree.admin_order_payment_path(order, originator),
        options
      )
    when :payments
      order = originator.payment.order
      link_to(
        Spree.t(link_options[:translation_key], { order_number: order.number }),
        spree.admin_order_payments_path(order),
        options
      )
    end
  end

  private

  # We cannot set the value for a User originator because the user class is not
  # defined when this module is loaded. Spree::UserClassHandle does not work
  # here either as the assignment is evaluated before Spree.user_class is set.
  def add_user_originator_link
    originator_links[Spree.user_class.to_s] = {
      new_tab: true,
      href_type: :user,
      translation_key: 'admin.store_credits.user_originator'
    }
  end
end
