# frozen_string_literal: true

module Spree
  module Core
    module Importer
      class Order
        def self.import(user, params)
          params = params.to_h
          ActiveRecord::Base.transaction do
            ensure_country_id_from_params params[:ship_address_attributes]
            ensure_state_id_from_params params[:ship_address_attributes]
            ensure_country_id_from_params params[:bill_address_attributes]
            ensure_state_id_from_params params[:bill_address_attributes]

            create_params = params.slice :currency
            order = Spree::Order.create! create_params
            order.store ||= Spree::Store.default
            order.associate_user!(user)
            order.save!

            shipments_attrs = params.delete(:shipments_attributes)

            create_line_items_from_params(params.delete(:line_items_attributes), order)
            create_shipments_from_params(shipments_attrs, order)
            create_adjustments_from_params(params.delete(:adjustments_attributes), order)
            create_payments_from_params(params.delete(:payments_attributes), order)

            params.delete(:user_id) unless user.try(:has_spree_role?, "admin") && params.key?(:user_id)

            completed_at = params.delete(:completed_at)

            order.update!(params)

            order.create_proposed_shipments unless shipments_attrs.present?

            if completed_at
              order.completed_at = completed_at
              order.state = 'complete'
              order.save!
            end

            # Really ensure that the order totals & states are correct
            order.updater.update
            if shipments_attrs.present?
              order.shipments.each_with_index do |shipment, index|
                shipment.update_columns(cost: shipments_attrs[index][:cost].to_f) if shipments_attrs[index][:cost].present?
              end
            end
            order.reload
          end
        end

        def self.create_shipments_from_params(shipments_hash, order)
          return [] unless shipments_hash

          shipments_hash.each do |target|
            shipment = Shipment.new
            shipment.tracking       = target[:tracking]
            shipment.stock_location = Spree::StockLocation.find_by(admin_name: target[:stock_location]) || Spree::StockLocation.find_by!(name: target[:stock_location])

            inventory_units = target[:inventory_units] || []
            inventory_units.each do |inventory_unit|
              ensure_variant_id_from_params(inventory_unit)

              unless line_item = order.line_items.find_by(variant_id: inventory_unit[:variant_id])
                line_item = order.contents.add(Spree::Variant.find(inventory_unit[:variant_id]), 1)
              end

              # Spree expects a Inventory Unit to always reference a line
              # item and variant otherwise users might get exceptions when
              # trying to view these units. Note the Importer might not be
              # able to find the line item if line_item.variant_id |= iu.variant_id
              shipment.inventory_units.new(
                variant_id: inventory_unit[:variant_id],
                line_item: line_item
              )
            end

            # Mark shipped if it should be.
            if target[:shipped_at].present?
              shipment.shipped_at = target[:shipped_at]
              shipment.state      = 'shipped'
              shipment.inventory_units.each do |unit|
                unit.state = 'shipped'
              end
            end

            order.shipments << shipment
            shipment.save!

            shipping_method = Spree::ShippingMethod.find_by(name: target[:shipping_method]) || Spree::ShippingMethod.find_by!(admin_name: target[:shipping_method])
            rate = shipment.shipping_rates.create!(shipping_method: shipping_method,
                                                   cost: target[:cost])
            shipment.selected_shipping_rate_id = rate.id
            shipment.update_amounts
          end
        end

        def self.create_line_items_from_params(line_items_hash, order)
          return {} unless line_items_hash
          line_items_hash.each_key do |key|
            extra_params = line_items_hash[key].except(:variant_id, :quantity, :sku)
            line_item = ensure_variant_id_from_params(line_items_hash[key])
            line_item = order.contents.add(Spree::Variant.find(line_item[:variant_id]), line_item[:quantity])
            # Raise any errors with saving to prevent import succeeding with line items failing silently.
            if extra_params.present?
              line_item.update!(extra_params)
            else
              line_item.save!
            end
          end
        end

        def self.create_adjustments_from_params(adjustments, order)
          return [] unless adjustments
          adjustments.each do |target|
            adjustment = order.adjustments.build(
              order:  order,
              amount: target[:amount].to_d,
              label:  target[:label]
            )
            adjustment.save!
            adjustment.finalize!
          end
        end

        def self.create_payments_from_params(payments_hash, order)
          return [] unless payments_hash
          payments_hash.each do |target|
            payment = order.payments.build order: order
            payment.amount = target[:amount].to_f
            # Order API should be using state as that's the normal payment field.
            # spree_wombat serializes payment state as status so imported orders should fall back to status field.
            payment.state = target[:state] || target[:status] || 'completed'
            payment.payment_method = Spree::PaymentMethod.find_by!(name: target[:payment_method])
            payment.source = create_source_payment_from_params(target[:source], payment) if target[:source]
            payment.save!
          end
        end

        def self.create_source_payment_from_params(source_hash, payment)
          Spree::CreditCard.create(
            month: source_hash[:month],
            year: source_hash[:year],
            cc_type: source_hash[:cc_type],
            last_digits: source_hash[:last_digits],
            name: source_hash[:name],
            payment_method: payment.payment_method,
            gateway_customer_profile_id: source_hash[:gateway_customer_profile_id],
            gateway_payment_profile_id: source_hash[:gateway_payment_profile_id],
            imported: true
          )
        end

        def self.ensure_variant_id_from_params(hash)
          sku = hash.delete(:sku)
          unless hash[:variant_id].present?
            hash[:variant_id] = Spree::Variant.with_prices.find_by!(sku: sku).id
          end
          hash
        end

        def self.ensure_country_id_from_params(address)
          return if address.nil? || address[:country_id].present? || address[:country].nil?

          search = {}
          if name = address[:country]['name']
            search[:name] = name
          elsif iso_name = address[:country]['iso_name']
            search[:iso_name] = iso_name.upcase
          elsif iso = address[:country]['iso']
            search[:iso] = iso.upcase
          elsif iso_three = address[:country]['iso3']
            search[:iso3] = iso_three.upcase
          end

          address.delete(:country)
          address[:country_id] = Spree::Country.where(search).first!.id
        end

        def self.ensure_state_id_from_params(address)
          return if address.nil? || address[:state_id].present? || address[:state].nil?

          search = {}
          if name = address[:state]['name']
            search[:name] = name
          elsif abbr = address[:state]['abbr']
            search[:abbr] = abbr.upcase
          end

          address.delete(:state)
          search[:country_id] = address[:country_id]

          if state = Spree::State.where(search).first
            address[:state_id] = state.id
          else
            address[:state_name] = search[:name] || search[:abbr]
          end
        end
      end
    end
  end
end
