# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Core
    RSpec.describe Importer::Order do
      let!(:store) { create(:store) }
      let!(:country) { create(:country) }
      let!(:state) { country.states.first || create(:state, country:) }
      let!(:stock_location) { create(:stock_location, admin_name: 'Admin Name') }

      let(:user) { stub_model(LegacyUser, email: 'fox@mudler.com') }
      let(:shipping_method) { create(:shipping_method) }
      let(:payment_method) { create(:check_payment_method) }

      let(:product) {
        product = Spree::Product.create(name: 'Test',
                                             sku: 'TEST-1',
                                             price: 33.22)
        product.shipping_category = create(:shipping_category)
        product.save
        product
      }

      let(:variant) {
        variant = product.master
        variant.stock_items.each { |si| si.set_count_on_hand(10) }
        variant
      }

      let(:sku) { variant.sku }
      let(:variant_id) { variant.id }

      let(:line_items) { { "0" => { variant_id: variant.id, quantity: 5 } } }
      let(:ship_address) {
        {
         address1: '123 Testable Way',
         name: 'Fox Mulder',
         firstname: 'Fox',
         lastname: 'Mulder',
         city: 'Washington',
         country_id: country.id,
         state_id: state.id,
         zipcode: '66666',
         phone: '666-666-6666'
      }}

      it 'can import an order number' do
        params = { number: '123-456-789' }
        order = Importer::Order.import(user, params)
        expect(order.number).to eq '123-456-789'
      end

      it 'optionally add completed at' do
        params = { email: 'test@test.com',
                   completed_at: Time.current,
                   line_items_attributes: line_items }
        order = Importer::Order.import(user, params)
        expect(order).to be_completed
        expect(order.state).to eq 'complete'
      end

      it "assigns order[email] over user email to order" do
        params = { email: 'wooowww@test.com' }
        order = Importer::Order.import(user, params)
        expect(order.email).to eq params[:email]
      end

      context "assigning a user to an order" do
        let(:other_user) { stub_model(LegacyUser, email: 'dana@scully.com') }

        context "as an admin" do
          before { allow(user).to receive_messages has_spree_role?: true }

          context "a user's id is not provided" do
            context "nil user id is provided" do
              it "unassociates the admin user from the order" do
                params = { user_id: nil }
                order = Importer::Order.import(user, params)
                expect(order.user_id).to be_nil
              end
            end

            context "another user's id is provided" do
              it "permits the user to be assigned" do
                params = { user_id: other_user.id }
                order = Importer::Order.import(user, params)
                expect(order.user_id).to eq(other_user.id)
              end
            end
          end

          context "a user's id is not provided" do
            it "doesn't unassociate the admin from the order" do
              params = {}
              order = Importer::Order.import(user, params)
              expect(order.user_id).to eq(user.id)
            end
          end
        end

        context "as a user" do
          before { allow(user).to receive_messages has_spree_role?: false }
          it "does not assign the order to the other user" do
            params = { user_id: other_user.id }
            order = Importer::Order.import(user, params)
            expect(order.user_id).to eq(user.id)
          end
        end
      end

      it 'can build an order from API with just line items' do
        params = { line_items_attributes: line_items }

        expect(Importer::Order).to receive(:ensure_variant_id_from_params).and_return({ variant_id: variant.id, quantity: 5 })
        order = Importer::Order.import(user, params)
        expect(order.user).to eq(nil)
        line_item = order.line_items.first
        expect(line_item.quantity).to eq(5)
        expect(line_item.variant_id).to eq(variant_id)
      end

      it 'handles line_item updating exceptions' do
        line_items['0'][:price] = 'an invalid price'
        params = { line_items_attributes: line_items }

        expect {
          Importer::Order.import(user, params)
        }.to raise_exception ActiveRecord::RecordInvalid
      end

      it 'can build an order from API with variant sku' do
        params = {
          line_items_attributes: {
            "0" => { sku:, quantity: 5 }
          }
        }

        order = Importer::Order.import(user, params)

        line_item = order.line_items.first
        expect(line_item.variant_id).to eq(variant_id)
        expect(line_item.quantity).to eq(5)
      end

      it 'handle when line items is an array' do
        params = {
          line_items_attributes: [
            { variant_id:, quantity: 7 }
          ]
        }
        order = Importer::Order.import(user, params)

        line_item = order.line_items.first
        expect(line_item.variant_id).to eq(variant_id)
        expect(line_item.quantity).to eq(7)
      end

      it 'can build an order from API shipping address' do
        params = { ship_address_attributes: ship_address,
                   line_items_attributes: line_items }

        order = Importer::Order.import(user, params)
        expect(order.ship_address.address1).to eq '123 Testable Way'
      end

      it 'can build an order from API with country attributes' do
        ship_address.delete(:country_id)
        ship_address[:country] = { 'iso' => 'US' }
        params = { ship_address_attributes: ship_address,
                   line_items_attributes: line_items }

        order = Importer::Order.import(user, params)
        expect(order.ship_address.country.iso).to eq 'US'
      end

      it 'can build an order from API with state attributes' do
        ship_address.delete(:state_id)
        ship_address[:state] = { 'name' => state.name }
        params = { ship_address_attributes: ship_address,
                   line_items_attributes: line_items }

        order = Importer::Order.import(user, params)
        expect(order.ship_address.state.name).to eq 'Alabama'
      end

      context "with a different currency" do
        let(:params) { { currency: "GBP" } }

        it "sets the order currency" do
          order = Importer::Order.import(user, params)
          expect(order.currency).to eq "GBP"
        end

        context "when a line item price is specified" do
          let(:params) { { currency: "GBP", line_items_attributes: line_items } }

          before { line_items["0"][:price] = 1.99 }

          context "and price is present in the order currency" do
            before { variant.prices.create(currency: "GBP", amount: 18.99) }

            it "assigns a price correctly" do
              order = Importer::Order.import(user, params)

              expect(order.currency).to eq "GBP"
              expect(order.line_items.first.price).to eq 1.99
              expect(order.line_items.first.currency).to eq "GBP"
            end
          end

          context "and no price is present in the order currency" do
            it "raises an exception" do
              expect {
                Importer::Order.import(user, params)
              }.to raise_exception ActiveRecord::RecordInvalid
            end
          end
        end
      end

      context "state passed is not associated with country" do
        let(:params) do
          {
            ship_address_attributes: ship_address,
            line_items_attributes: line_items
          }
        end

        let(:other_state) { create(:state, name: "Uhuhuh", country: create(:country)) }

        before do
          ship_address.delete(:state_id)
          ship_address[:state] = { 'name' => other_state.name }
        end

        it 'sets states name instead of state id' do
          order = Importer::Order.import(user, params)
          expect(order.ship_address.state_name).to eq other_state.name
        end
      end

      it 'sets state name if state record not found' do
        ship_address.delete(:state_id)
        ship_address[:state] = { 'name' => 'XXX' }
        params = { ship_address_attributes: ship_address,
                   line_items_attributes: line_items }

        order = Importer::Order.import(user, params)
        expect(order.ship_address.state_name).to eq 'XXX'
      end

      context 'variant not deleted' do
        it 'ensures variant id from api' do
          hash = { sku: variant.sku }
          Importer::Order.ensure_variant_id_from_params(hash)
          expect(hash[:variant_id]).to eq variant.id
        end
      end

      context 'variant was soft-deleted' do
        it 'raise error as variant shouldnt be found' do
          variant.product.discard
          hash = { sku: variant.sku }
          expect {
            Importer::Order.ensure_variant_id_from_params(hash)
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      it 'ensures_country_id for country fields' do
        [:name, :iso, :iso_name, :iso3].each do |field|
          address = { country: { field => country.send(field) } }
          Importer::Order.ensure_country_id_from_params(address)
          expect(address[:country_id]).to eq country.id
        end
      end

      it "raises with proper message when cant find country" do
        address = { country: { "name" => "NoNoCountry" } }
        expect {
          Importer::Order.ensure_country_id_from_params(address)
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'ensures_state_id for state fields' do
        [:name, :abbr].each do |field|
          address = { country_id: country.id, state: { field => state.send(field) } }
          Importer::Order.ensure_state_id_from_params(address)
          expect(address[:state_id]).to eq state.id
        end
      end

      context "shipments" do
        let(:params) do
          {
            shipments_attributes: [
              {
                tracking: '123456789',
                cost: '14.99',
                shipping_method: shipping_method.name,
                stock_location: stock_location.name,
                inventory_units: [{ sku: }]
              }
            ]
          }
        end

        it 'ensures variant exists and is not deleted' do
          expect(Importer::Order).to receive(:ensure_variant_id_from_params).and_call_original
          Importer::Order.import(user, params)
        end

        it 'builds them properly' do
          order = Importer::Order.import(user, params)
          shipment = order.shipments.first

          expect(shipment.cost.to_f).to eq 14.99
          expect(shipment.inventory_units.first.variant_id).to eq product.master.id
          expect(shipment.tracking).to eq '123456789'
          expect(shipment.shipping_rates.first.cost).to eq 14.99
          expect(shipment.selected_shipping_rate).to eq(shipment.shipping_rates.first)
          expect(shipment.stock_location).to eq stock_location
          expect(order.shipment_total.to_f).to eq 14.99
        end

        it "accepts admin name for stock location" do
          params[:shipments_attributes][0][:stock_location] = stock_location.admin_name
          order = Importer::Order.import(user, params)
          shipment = order.shipments.first

          expect(shipment.stock_location).to eq stock_location
        end

        it "raises if cant find stock location" do
          params[:shipments_attributes][0][:stock_location] = "doesnt exist"
          expect {
            Importer::Order.import(user, params)
          }.to raise_error ActiveRecord::RecordNotFound
        end

        it "accepts stock_location_id" do
          params[:shipments_attributes][0][:stock_location] = nil
          params[:shipments_attributes][0][:stock_location_id] = stock_location.id
          order = Importer::Order.import(user, params)
          shipment = order.shipments.first

          expect(shipment.stock_location).to eq stock_location
        end

        context 'when completed_at and shipped_at present' do
          let(:params) do
            {
              completed_at: 2.days.ago,
              shipments_attributes: [
                {
                  tracking: '123456789',
                  cost: '4.99',
                  shipped_at: 1.day.ago,
                  shipping_method: shipping_method.name,
                  stock_location: stock_location.name,
                  inventory_units: [{ sku: }]
                }
              ]
            }
          end

          it 'builds them properly' do
            order = Importer::Order.import(user, params)
            shipment = order.shipments.first

            expect(shipment.cost.to_f).to eq 4.99
            expect(shipment.inventory_units.first.variant_id).to eq product.master.id
            expect(shipment.tracking).to eq '123456789'
            expect(shipment.shipped_at).to be_present
            expect(shipment.shipping_rates.first.cost).to eq 4.99
            expect(shipment.selected_shipping_rate).to eq(shipment.shipping_rates.first)
            expect(shipment.stock_location).to eq stock_location
            expect(shipment.state).to eq('shipped')
            expect(shipment.inventory_units.all?(&:shipped?)).to be true
            expect(order.shipment_state).to eq('shipped')
            expect(order.shipment_total.to_f).to eq 4.99
          end
        end

        context "when line items and shipments are present" do
          let(:params) do
            {
              completed_at: 2.days.ago,
              line_items_attributes: line_items,
              shipments_attributes: [
                {
                  tracking: '123456789',
                  cost: '4.99',
                  shipped_at: 1.day.ago,
                  shipping_method: shipping_method.name,
                  stock_location: stock_location.name,
                  inventory_units: [{ sku: }]
                }
              ]
            }
          end

          it 'builds quantities properly' do
            order = Importer::Order.import(user, params)
            line_item = order.line_items.first
            expect(line_item.quantity).to eq(5)
          end
        end
      end

      it 'adds adjustments' do
        params = {
          adjustments_attributes: [
            { label: 'Shipping Discount', amount: -4.99 },
            { label: 'Promotion Discount', amount: -3.00 }
          ]
        }

        order = Importer::Order.import(user, params)
        expect(order.adjustments.all?(&:finalized?)).to be true
        expect(order.adjustments.first.label).to eq 'Shipping Discount'
        expect(order.adjustments.first.amount).to eq(-4.99)
      end

      it "calculates final order total correctly" do
        params = {
          adjustments_attributes: [
            { label: 'Promotion Discount', amount: -3.00 }
          ],
          line_items_attributes: {
            "0" => {
              variant_id: variant.id,
              quantity: 5
            }
          }
        }

        order = Importer::Order.import(user, params)
        expect(order.item_total).to eq(166.1)
        expect(order.total).to eq(163.1) # = item_total (166.1) - adjustment_total (3.00)
      end

      it 'builds a payment using state' do
        params = { payments_attributes: [{ amount: '4.99',
                                              payment_method: payment_method.name,
                                              state: 'completed' }] }
        order = Importer::Order.import(user, params)
        expect(order.payments.first.amount).to eq 4.99
      end

      it 'builds a payment using status as fallback' do
        params = { payments_attributes: [{ amount: '4.99',
                                              payment_method: payment_method.name,
                                              status: 'completed' }] }
        order = Importer::Order.import(user, params)
        expect(order.payments.first.amount).to eq 4.99
      end

      it 'build a source payment using years and month' do
        params = { payments_attributes: [{
                                              amount: '4.99',
                                              payment_method: payment_method.name,
                                              status: 'completed',
                                              source: {
                                                name: 'Fox',
                                                last_digits: "7424",
                                                cc_type: "visa",
                                                year: '2022',
                                                month: "5"
                                              }
                                            }] }

        order = Importer::Order.import(user, params)
        expect(order.payments.first.source.last_digits).to eq '7424'
      end

      it 'handles source building exceptions when do not have years and month' do
        params = { payments_attributes: [{
                                              amount: '4.99',
                                              payment_method: payment_method.name,
                                              status: 'completed',
                                              source: {
                                                name: 'Fox',
                                                last_digits: "7424",
                                                cc_type: "visa"
                                              }
                                            }] }

        expect {
          Importer::Order.import(user, params)
        }.to raise_error /Validation failed: Credit card Month is not a number, Credit card Year is not a number/
      end

      context "raises error" do
        it "clears out order from db" do
          params = { payments_attributes: [{ payment_method: "XXX" }] }
          count = Order.count

          expect { Importer::Order.import(user, params) }.to raise_error ActiveRecord::RecordNotFound
          expect(Order.count).to eq count
        end
      end
    end
  end
end
