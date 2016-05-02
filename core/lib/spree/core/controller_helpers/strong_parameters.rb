module Spree
  module Core
    module ControllerHelpers
      module StrongParameters
        def base_attributes
          Spree::PermittedAttributes
        end

        delegate(*Spree::PermittedAttributes::ATTRIBUTES,
                 to: :base_attributes,
                 prefix: :permitted)

        def admin_attributes
          Spree::PermittedAttributes::Admin
        end

        delegate(*Spree::PermittedAttributes::Admin::ATTRIBUTES,
                 to: :admin_attributes,
                 prefix: :permitted_admin)

        def permitted_credit_card_update_attributes
          base_attributes.credit_card_update_attributes + [
            address_attributes: permitted_address_attributes
          ]
        end

        def permitted_line_item_attributes
          base_attributes.line_item_attributes + [
            options: base_attributes.line_item_option_attributes
          ]
        end

        def permitted_admin_line_item_attributes
          base_attributes.line_item_attributes + admin_attributes.line_item_attributes + [
<<<<<<< HEAD
            options: base_attributes.line_item_option_attributes + admin_attributes.line_item_option_attributes
=======
            options: base_attributes.line_item_option_attributes +  admin_attributes.line_item_option_attributes
>>>>>>> 3862505... Simplify order_contents line_item add
          ]
        end

        def permitted_payment_attributes
          base_attributes.payment_attributes + [
            source_attributes: permitted_source_attributes
          ]
        end

        def permitted_source_attributes
          base_attributes.source_attributes + [
            address_attributes: permitted_address_attributes
          ]
        end

        def permitted_checkout_attributes
          base_attributes.checkout_attributes + [
            bill_address_attributes: permitted_address_attributes,
            ship_address_attributes: permitted_address_attributes,
            payments_attributes: permitted_payment_attributes,
            shipments_attributes: permitted_shipment_attributes
          ]
        end

        def permitted_order_attributes
          permitted_checkout_attributes + [
            line_items_attributes: permitted_line_item_attributes
          ]
        end

        def permitted_admin_order_attributes
          permitted_checkout_attributes + admin_attributes.order_attributes + [
            line_items_attributes: permitted_admin_line_item_attributes
          ]
        end

        def permitted_product_attributes
          base_attributes.product_attributes + [
            product_properties_attributes: permitted_product_properties_attributes
          ]
        end

        def permitted_user_attributes
          base_attributes.user_attributes + [
            bill_address_attributes: permitted_address_attributes,
            ship_address_attributes: permitted_address_attributes
          ]
        end
      end
    end
  end
end
