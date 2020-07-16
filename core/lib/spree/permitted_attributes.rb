# frozen_string_literal: true

module Spree
  # Spree::PermittedAttributes contains the attributes permitted through strong
  # params in various controllers in the frontend. Extensions and stores that
  # need additional params to be accepted can mutate these arrays to add them.
  module PermittedAttributes
    ATTRIBUTES = [
      :address_attributes,
      :address_book_attributes,
      :checkout_address_attributes,
      :checkout_delivery_attributes,
      :checkout_payment_attributes,
      :checkout_confirm_attributes,
      :credit_card_update_attributes,
      :customer_return_attributes,
      :image_attributes,
      :inventory_unit_attributes,
      :line_item_attributes,
      :option_type_attributes,
      :option_value_attributes,
      :payment_attributes,
      :product_attributes,
      :product_properties_attributes,
      :property_attributes,
      :return_authorization_attributes,
      :shipment_attributes,
      :source_attributes,
      :stock_item_attributes,
      :stock_location_attributes,
      :stock_movement_attributes,
      :store_attributes,
      :taxon_attributes,
      :taxonomy_attributes,
      :user_attributes,
      :variant_attributes
    ]

    mattr_reader(*ATTRIBUTES)

    @@address_attributes = [
      :id, :firstname, :lastname, :first_name, :last_name,
      :address1, :address2, :city, :country_id, :state_id,
      :zipcode, :phone, :state_name, :country_iso, :alternative_phone, :company,
      country: [:iso, :name, :iso3, :iso_name],
      state: [:name, :abbr]
    ]

    @@address_book_attributes = address_attributes + [:default]

    @@credit_card_update_attributes = [
      :month, :year, :expiry, :first_name, :last_name, :name
    ]

    @@customer_return_attributes = [:stock_location_id, return_items_attributes: [:id, :inventory_unit_id, :return_authorization_id, :returned, :amount, :reception_status_event, :acceptance_status, :exchange_variant_id, :resellable]]

    @@image_attributes = [:alt, :attachment, :position, :viewable_type, :viewable_id]

    @@inventory_unit_attributes = [:shipment, :variant_id]

    @@line_item_attributes = [:id, :variant_id, :quantity]

    @@option_type_attributes = [:name, :presentation, :option_values_attributes]

    @@option_value_attributes = [:name, :presentation]

    @@payment_attributes = [:amount, :payment_method_id, :payment_method]

    @@product_properties_attributes = [:property_name, :value, :position]

    @@product_attributes = [
      :name, :description, :available_on, :permalink, :meta_description,
      :meta_keywords, :price, :sku, :deleted_at,
      :option_values_hash, :weight, :height, :width, :depth,
      :shipping_category_id, :tax_category_id,
      :taxon_ids, :option_type_ids, :cost_currency, :cost_price
    ]

    @@property_attributes = [:name, :presentation]

    @@return_authorization_attributes = [:memo, :stock_location_id, :return_reason_id, return_items_attributes: [:inventory_unit_id, :exchange_variant_id, :return_reason_id, :preferred_reimbursement_type_id]]

    @@shipment_attributes = [
      :special_instructions, :stock_location_id, :id, :tracking,
      :selected_shipping_rate_id
    ]

    # month / year may be provided by some sources, or others may elect to use one field
    @@source_attributes = [
      :number, :month, :year, :expiry, :verification_value,
      :first_name, :last_name, :cc_type, :gateway_customer_profile_id,
      :gateway_payment_profile_id, :last_digits, :name, :encrypted_data,
      :existing_card_id, :wallet_payment_source_id, address_attributes: address_attributes
    ]

    @@stock_item_attributes = [:variant, :stock_location, :backorderable, :variant_id]

    @@stock_location_attributes = [
      :name, :active, :address1, :address2, :city, :zipcode,
      :backorderable_default, :state_name, :state_id, :country_id, :phone,
      :propagate_all_variants
    ]

    @@stock_movement_attributes = [
      :quantity, :stock_item, :stock_item_id, :originator, :action
    ]

    @@store_attributes = [:name, :url, :seo_title, :meta_keywords,
                          :meta_description, :default_currency,
                          :mail_from_address, :cart_tax_country_iso]

    @@taxonomy_attributes = [:name]

    @@taxon_attributes = [
      :name, :parent_id, :position, :icon, :description, :permalink, :taxonomy_id,
      :meta_description, :meta_keywords, :meta_title, :child_index
    ]

    # Intentionally leaving off email here to prevent privilege escalation
    # by changing a user with higher priveleges' email to one a lower-priveleged
    # admin owns. Creating a user with an email is handled separate at the
    # controller level.
    @@user_attributes = [:password, :password_confirmation]

    @@variant_attributes = [
      :name, :presentation, :cost_price, :lock_version,
      :position, :track_inventory,
      :product_id, :product, :option_values_attributes, :price,
      :weight, :height, :width, :depth, :sku, :cost_currency, option_value_ids: [], options: [:name, :value]
    ]

    @@checkout_address_attributes = [
      :use_billing,
      :email,
      bill_address_attributes: address_attributes,
      ship_address_attributes: address_attributes
    ]

    @@checkout_delivery_attributes = [
      :special_instructions,
      shipments_attributes: shipment_attributes
    ]

    @@checkout_payment_attributes = [
      :coupon_code,
      payments_attributes: payment_attributes + [
        source_attributes: source_attributes
      ]
    ]

    @@checkout_confirm_attributes = []

    def self.checkout_attributes
      Spree::Deprecation.warn <<-WARN.squish, caller
        checkout_attributes is deprecated, please use the permitted
        attributes set for the specific step that needs to be updated.

        E.g. permitted_checkout_address_attributes
      WARN

      CheckoutAdditionalAttributes.new(
        checkout_address_attributes +
        checkout_delivery_attributes +
        checkout_payment_attributes +
        checkout_confirm_attributes
      )
    end
  end

  class CheckoutAdditionalAttributes < Array
    def <<(*attributes)
      super

      inject_attributes_to_all_steps(attributes, :<<)
    end

    def push(*attributes)
      super

      inject_attributes_to_all_steps(attributes, :push)
    end
    alias append push

    def prepend(*attributes)
      super

      inject_attributes_to_all_steps(attributes, :prepend)
    end
    alias unshift prepend

    private

    def inject_attributes_to_all_steps(attributes, method)
      attributes.each do |attribute|
        PermittedAttributes.checkout_address_attributes.send(method, attribute)
        PermittedAttributes.checkout_delivery_attributes.send(method, attribute)
        PermittedAttributes.checkout_payment_attributes.send(method, attribute)
        PermittedAttributes.checkout_confirm_attributes.send(method, attribute)
      end
    end
  end
end
