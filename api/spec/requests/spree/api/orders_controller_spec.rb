# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::OrdersController, type: :request do
    let!(:order) { create(:order) }
    let(:variant) { create(:variant) }
    let(:line_item) { create(:line_item) }

    let(:attributes) {
      [:number, :item_total, :display_total, :total,
       :state, :adjustment_total,
       :user_id, :created_at, :updated_at,
       :completed_at, :payment_total, :shipment_state,
       :payment_state, :email, :special_instructions,
       :total_quantity, :display_item_total, :currency]
    }

    let(:address_params) { { country_id: Country.first.id, state_id: State.first.id } }

    let(:current_api_user) do
      user = Spree.user_class.new(email: "spree@example.com")
      user.generate_spree_api_key!
      user
    end

    before do
      stub_authentication!
    end

    describe "POST create" do
      let(:target_user) { create :user }
      let(:date_override) { Time.parse('2015-01-01') }
      let(:attributes) { { user_id: target_user.id, created_at: date_override, email: target_user.email } }

      subject do
        post spree.api_orders_path, params: { order: attributes }
        response
      end

      context "when the current user cannot administrate the order" do
        custom_authorization! do |_|
          can :create, Spree::Order
        end

        it "does not include unpermitted params, or allow overriding the user" do
          subject
          expect(response).to be_successful
          order = Spree::Order.last
          expect(order.user).to eq current_api_user
          expect(order.email).to eq target_user.email
        end

        it { is_expected.to be_successful }

        context 'creating payment' do
          let(:attributes) { super().merge(payments_attributes: [{ payment_method_id: payment_method.id }]) }

          context "with allowed payment method" do
            let!(:payment_method) { create(:check_payment_method, name: "allowed" ) }
            it { is_expected.to be_successful }
            it "creates a payment" do
              expect {
                subject
              }.to change { Spree::Payment.count }.by(1)
            end
          end

          context "with disallowed payment method" do
            let!(:payment_method) { create(:check_payment_method, name: "forbidden", available_to_users: false) }
            it { is_expected.to be_not_found }
            it "creates no payments" do
              expect {
                subject
              }.not_to change { Spree::Payment.count }
            end
          end
        end

        context "with existing promotion" do
          let(:discount) { 2 }
          before do
            create(:promotion, :with_line_item_adjustment, apply_automatically: true, adjustment_rate: discount )
          end

          it "activates the promotion" do
            post spree.api_orders_path, params: { order: { line_items: { "0" => { variant_id: variant.to_param, quantity: 1 } } } }
            order = Order.last
            line_item = order.line_items.first
            expect(order.total).to eq(line_item.price - discount)
          end
        end
      end

      context "when the current user can administrate the order" do
        custom_authorization! do |_|
          can [:admin, :create], Spree::Order
        end

        it "it permits all params and allows overriding the user" do
          subject
          order = Spree::Order.last
          expect(order.user).to eq target_user
          expect(order.email).to eq target_user.email
          expect(order.created_at).to eq date_override
        end

        it { is_expected.to be_successful }
      end

      context 'when the line items have custom attributes' do
        it "can create an order with line items that have custom permitted attributes" do
          PermittedAttributes.line_item_attributes << { options: [:some_option] }
          without_partial_double_verification do
            expect_any_instance_of(Spree::LineItem).to receive(:some_option=).once.with('4')
          end
          post spree.api_orders_path, params: { order: { line_items: { "0" => { variant_id: variant.to_param, quantity: 5, options: { some_option: 4 } } } } }
          expect(response.status).to eq(201)
          order = Order.last
          expect(order.line_items.count).to eq(1)
        end
      end
    end

    describe "PUT update" do
      let(:user) { create :user }
      let(:order_params) { { number: "anothernumber", user_id: user.id, email: "foo@foobar.com" } }
      let(:can_admin) { false }
      subject do
        put spree.api_order_path(order), params: { order: order_params }
        response
      end

      context "when the user cannot administer the order" do
        custom_authorization! do |_|
          can [:update], Spree::Order
        end

        it "updates the user's email" do
          expect {
            subject
          }.to change { order.reload.email }.to("foo@foobar.com")
        end

        it { is_expected.to be_successful }

        it "does not associate users" do
          expect {
            subject
          }.not_to change { order.reload.user }
        end

        it "does not change forbidden attributes" do
          expect {
            subject
          }.to_not change{ order.reload.number }
        end

        context 'creating payment' do
          let(:order_params) { super().merge(payments_attributes: [{ payment_method_id: payment_method.id }]) }

          context "with allowed payment method" do
            let!(:payment_method) { create(:check_payment_method, name: "allowed" ) }
            it { is_expected.to be_successful }
            it "creates a payment" do
              expect {
                subject
              }.to change { Spree::Payment.count }.by(1)
            end
          end

          context "with disallowed payment method" do
            let!(:payment_method) { create(:check_payment_method, name: "forbidden", available_to_users: false) }
            it { is_expected.to be_not_found }
            it "creates no payments" do
              expect {
                subject
              }.not_to change { Spree::Payment.count }
            end
          end
        end
      end

      context "when the user can administer the order" do
        custom_authorization! do |_|
          can [:admin, :update], Spree::Order
        end

        it "will associate users" do
          expect {
            subject
          }.to change { order.reload.user }.to(user)
        end

        it "updates the otherwise forbidden attributes" do
          expect{ subject }.to change{ order.reload.number }.
            to("anothernumber")
        end
      end
    end

    it "cannot view all orders" do
      get spree.api_orders_path
      assert_unauthorized!
    end

    context "the current api user does not exist" do
      let(:current_api_user) { nil }

      it "returns a 401" do
        get spree.api_my_orders_path
        expect(response.status).to eq(401)
      end
    end

    context "the current api user is authenticated" do
      let(:current_api_user) { order.user }
      let(:store) { create(:store) }
      let(:order) { create(:order, line_items: [line_item], store: store) }

      it "can view all of their own orders for the current store" do
        get spree.api_my_orders_path, headers: { 'SERVER_NAME' => store.url }

        expect(response.status).to eq(200)
        expect(json_response["pages"]).to eq(1)
        expect(json_response["current_page"]).to eq(1)
        expect(json_response["orders"].length).to eq(1)
        expect(json_response["orders"].first["number"]).to eq(order.number)
        expect(json_response["orders"].first["line_items"].length).to eq(1)
        expect(json_response["orders"].first["line_items"].first["id"]).to eq(line_item.id)
      end

      it "cannot view orders for a different store" do
        get spree.api_my_orders_path, headers: { 'SERVER_NAME' => 'foo' }

        expect(response.status).to eq(200)
        expect(json_response["orders"].length).to eq(0)
      end

      it "can filter the returned results" do
        get spree.api_my_orders_path, params: { q: { completed_at_not_null: 1 } }, headers: { 'SERVER_NAME' => store.url }

        expect(response.status).to eq(200)
        expect(json_response["orders"].length).to eq(0)
      end

      it "returns orders in reverse chronological order by completed_at" do
        order.update_columns completed_at: Time.current, created_at: 3.days.ago

        order_two = Order.create user: order.user, completed_at: Time.current - 1.day, created_at: 2.days.ago, store: store
        expect(order_two.created_at).to be > order.created_at
        order_three = Order.create user: order.user, completed_at: nil, created_at: 1.day.ago, store: store
        expect(order_three.created_at).to be > order_two.created_at
        order_four = Order.create user: order.user, completed_at: nil, created_at: 0.days.ago, store: store
        expect(order_four.created_at).to be > order_three.created_at

        get spree.api_my_orders_path, headers: { 'SERVER_NAME' => store.url }
        expect(response.status).to eq(200)
        expect(json_response["pages"]).to eq(1)
        orders = json_response["orders"]
        expect(orders.length).to eq(4)
        expect(orders[0]["number"]).to eq(order.number)
        expect(orders[1]["number"]).to eq(order_two.number)
        expect([orders[2]["number"], orders[3]["number"]]).to match_array([order_three.number, order_four.number])
      end
    end

    describe 'current' do
      let(:current_api_user) { order.user }
      let!(:order) { create(:order, line_items: [line_item]) }

      it "uses the user's last_incomplete_spree_order logic with the current store" do
        expect(current_api_user).to receive(:last_incomplete_spree_order).with(store: Spree::Store.default)
        get spree.api_current_order_path(format: 'json')
      end
    end

    it "can view their own order" do
      allow_any_instance_of(Order).to receive_messages user: current_api_user
      get spree.api_order_path(order)
      expect(response.status).to eq(200)
      expect(json_response).to have_attributes(attributes)
      expect(json_response["adjustments"]).to be_empty
    end

    describe 'GET #show' do
      let(:order) { create :order_with_line_items }
      let(:adjustment) { FactoryBot.create(:adjustment, adjustable: order, order: order) }

      subject { get spree.api_order_path(order) }

      before do
        allow_any_instance_of(Order).to receive_messages user: current_api_user
      end

      context 'when inventory information is present' do
        it 'contains stock information on variant' do
          subject
          variant = json_response['line_items'][0]['variant']
          expect(variant).to_not be_nil
          expect(variant['in_stock']).to eq(false)
          expect(variant['total_on_hand']).to eq(0)
          expect(variant['is_backorderable']).to eq(true)
          expect(variant['is_destroyed']).to eq(false)
        end
      end

      context 'when an item does not track inventory' do
        before do
          order.line_items.first.variant.update!(track_inventory: false)
        end

        it 'contains stock information on variant' do
          subject
          variant = json_response['line_items'][0]['variant']
          expect(variant).to_not be_nil
          expect(variant['in_stock']).to eq(true)
          expect(variant['total_on_hand']).to eq(nil)
          expect(variant['is_backorderable']).to eq(true)
          expect(variant['is_destroyed']).to eq(false)
        end
      end

      context 'when shipment adjustments are present' do
        before do
          order.shipments.first.adjustments << adjustment
        end

        it 'contains adjustments on shipment' do
          subject

          # Test to insure shipment has adjustments
          shipment = json_response['shipments'][0]
          expect(shipment).to_not be_nil
          expect(shipment['adjustments'][0]).not_to be_empty
          expect(shipment['adjustments'][0]['label']).to eq(adjustment.label)
        end
      end

      context 'when credit cards are present' do
        let!(:payment) { create(:credit_card_payment, order: order, source: credit_card) }
        let(:credit_card) { create(:credit_card, address: create(:address)) }

        it 'contains the credit cards' do
          subject

          credit_cards = json_response['credit_cards']
          expect(credit_cards.size).to eq 1
          expect(credit_cards[0]['id']).to eq payment.source.id
          expect(credit_cards[0]['address']['id']).to eq credit_card.address_id
        end

        it 'renders the payment source view for gateway' do
          subject
          expect(response).to render_template partial: 'spree/api/payments/source_views/_gateway'
        end
      end

      context 'when store credit is present' do
        let!(:payment) { create(:store_credit_payment, order: order, source: store_credit) }
        let(:store_credit) { create(:store_credit) }

        it 'renders the payment source view for store credit' do
          subject
          expect(response).to render_template partial: 'spree/api/payments/source_views/_store_credit'
        end
      end
    end

    it "orders contain the basic checkout steps" do
      allow_any_instance_of(Order).to receive_messages user: current_api_user
      get spree.api_order_path(order)
      expect(response.status).to eq(200)
      expect(json_response["checkout_steps"]).to eq(%w[address delivery confirm complete])
    end

    it "can not view someone else's order" do
      allow_any_instance_of(Order).to receive_messages user: stub_model(Spree::LegacyUser)
      get spree.api_order_path(order)
      assert_unauthorized!
    end

    it "can view an order if the token is known" do
      get spree.api_order_path(order), params: { order_token: order.guest_token }
      expect(response.status).to eq(200)
    end

    it "can view an order if the token is passed in header" do
      get spree.api_order_path(order), headers: { "X-Spree-Order-Token" => order.guest_token }
      expect(response.status).to eq(200)
    end

    it "cannot cancel an order that doesn't belong to them" do
      order.update_attribute(:completed_at, Time.current)
      order.update_attribute(:shipment_state, "ready")
      put spree.cancel_api_order_path(order)
      assert_unauthorized!
    end

    it "can create an order" do
      post spree.api_orders_path, params: { order: { line_items: { "0" => { variant_id: variant.to_param, quantity: 5 } } } }
      expect(response.status).to eq(201)

      order = Order.last
      expect(order.line_items.count).to eq(1)
      expect(order.line_items.first.variant).to eq(variant)
      expect(order.line_items.first.quantity).to eq(5)

      expect(json_response['number']).to be_present
      expect(json_response["token"]).not_to be_blank
      expect(json_response["state"]).to eq("cart")
      expect(order.user).to eq(current_api_user)
      expect(order.email).to eq(current_api_user.email)
      expect(json_response["user_id"]).to eq(current_api_user.id)
    end

    it "assigns email when creating a new order" do
      post spree.api_orders_path, params: { order: { email: "guest@spreecommerce.com" } }
      expect(json_response['email']).not_to eq controller.current_api_user
      expect(json_response['email']).to eq "guest@spreecommerce.com"
    end

    context "specifying additional parameters for a line items" do
      # Regression test for https://github.com/spree/spree/issues/3404
      it "is allowed on line item level" do
        without_partial_double_verification do
          expect_any_instance_of(Spree::LineItem).to receive(:special=).with("foo")
        end

        allow_any_instance_of(Spree::Api::OrdersController).to receive_messages(permitted_line_item_attributes: [:id, :variant_id, :quantity, :special])
        post spree.api_orders_path, params: {
          order: {
            line_items: {
              "0" => {
                variant_id: variant.to_param, quantity: 5, special: "foo"
              }
            }
          }
        }
        expect(response.status).to eq(201)
      end

      it "is allowed using options parameter" do
        without_partial_double_verification do
          expect_any_instance_of(Spree::LineItem).to receive(:special=).with("foo")
        end

        allow_any_instance_of(Spree::Api::OrdersController).to receive_messages(permitted_line_item_attributes: [:id, :variant_id, :quantity, options: :special])
        post spree.api_orders_path, params: {
          order: {
            line_items: {
              "0" => {
                variant_id: variant.to_param, quantity: 5, options: { special: "foo" }
              }
            }
          }
        }
        expect(response.status).to eq(201)
      end
    end

    it "cannot arbitrarily set the line items price" do
      post spree.api_orders_path, params: {
        order: {
          line_items: {
            "0" => {
              price: 33.0, variant_id: variant.to_param, quantity: 5
            }
          }
        }
      }

      expect(response.status).to eq 201
      expect(Order.last.line_items.first.price.to_f).to eq(variant.price)
    end

    context "admin user imports order" do
      let!(:current_api_user) { create :admin_user }

      it "is able to set any default unpermitted attribute" do
        post spree.api_orders_path, params: { order: { number: "WOW" } }
        expect(response.status).to eq 201
        expect(json_response['number']).to eq "WOW"
      end
    end

    it "can create an order without any parameters" do
      post spree.api_orders_path
      expect(response.status).to eq(201)
      expect(json_response["state"]).to eq("cart")
    end

    context "working with an order" do
      let(:variant) { create(:variant) }
      let!(:line_item) { order.contents.add(variant, 1) }
      let!(:payment_method) { create(:check_payment_method) }

      let(:address_params) { { country_id: country.id } }
      let(:billing_address) {
        { name: "Tiago Motta", address1: "Av Paulista",
                                city: "Sao Paulo", zipcode: "01310-300", phone: "12345678",
                                country_id: country.id }
      }
      let(:shipping_address) {
        { name: "Tiago Motta", address1: "Av Paulista",
                                 city: "Sao Paulo", zipcode: "01310-300", phone: "12345678",
                                 country_id: country.id }
      }
      let(:country) { create(:country, { name: "Brazil", iso_name: "BRAZIL", iso: "BR", iso3: "BRA", numcode: 76 }) }

      before { allow_any_instance_of(Order).to receive_messages user: current_api_user }

      it "updates quantities of existing line items" do
        put spree.api_order_path(order), params: { order: {
          line_items: {
            "0" => { id: line_item.id, quantity: 10 }
          }
        } }

        expect(response.status).to eq(200)
        expect(json_response['line_items'].count).to eq(1)
        expect(json_response['line_items'].first['quantity']).to eq(10)
      end

      it "adds an extra line item" do
        variant_two = create(:variant)
        put spree.api_order_path(order), params: { order: {
          line_items: {
            "0" => { id: line_item.id, quantity: 10 },
            "1" => { variant_id: variant_two.id, quantity: 1 }
          }
        } }

        expect(response.status).to eq(200)
        expect(json_response['line_items'].count).to eq(2)
        expect(json_response['line_items'][0]['quantity']).to eq(10)
        expect(json_response['line_items'][1]['variant_id']).to eq(variant_two.id)
        expect(json_response['line_items'][1]['quantity']).to eq(1)
      end

      it "cannot change the price of an existing line item" do
        put spree.api_order_path(order), params: { order: {
          line_items: {
            0 => { id: line_item.id, price: 0 }
          }
        } }

        expect(response.status).to eq(200)
        expect(json_response['line_items'].count).to eq(1)
        expect(json_response['line_items'].first['price'].to_f).to_not eq(0)
        expect(json_response['line_items'].first['price'].to_f).to eq(line_item.variant.price)
      end

      it "can add billing address" do
        put spree.api_order_path(order), params: { order: { bill_address_attributes: billing_address } }

        expect(order.reload.bill_address).to_not be_nil
      end

      it "receives error message if trying to add billing address with errors" do
        billing_address[:city] = ""

        put spree.api_order_path(order), params: { order: { bill_address_attributes: billing_address } }

        expect(json_response['error']).not_to be_nil
        expect(json_response['errors']).not_to be_nil
        expect(json_response['errors']['bill_address.city'].first).to eq "can't be blank"
      end

      it "can add shipping address" do
        order.update!(ship_address_id: nil)

        expect {
          put spree.api_order_path(order), params: { order: { ship_address_attributes: shipping_address } }
        }.to change { order.reload.ship_address }.from(nil)
      end

      it "receives error message if trying to add shipping address with errors" do
        order.update!(ship_address_id: nil)

        shipping_address[:city] = ""

        put spree.api_order_path(order), params: { order: { ship_address_attributes: shipping_address } }

        expect(json_response['error']).not_to be_nil
        expect(json_response['errors']).not_to be_nil
        expect(json_response['errors']['ship_address.city'].first).to eq "can't be blank"
      end

      it "cannot set the user_id for the order" do
        user = Spree.user_class.create
        original_id = order.user_id
        put spree.api_order_path(order), params: { order: { user_id: user.id } }
        expect(response.status).to eq 200
        expect(json_response["user_id"]).to eq(original_id)
      end

      context "order has shipments" do
        before { order.create_proposed_shipments }

        it "clears out all existing shipments on line item update" do
          put spree.api_order_path(order), params: { order: {
            line_items: {
              0 => { id: line_item.id, quantity: 10 }
            }
          } }
          expect(order.reload.shipments).to be_empty
        end
      end

      context "with a line item" do
        let(:order) { create(:order_with_line_items) }
        let(:line_item) { order.line_items.first }

        it "can empty an order" do
          create(:adjustment, order: order, adjustable: order)
          put spree.empty_api_order_path(order)
          expect(response.status).to eq(204)
          order.reload
          expect(order.line_items).to be_empty
          expect(order.adjustments).to be_empty
        end

        it "can list its line items with images" do
          order.line_items.first.variant.images.create!(attachment: image("thinking-cat.jpg"))

          get spree.api_order_path(order)

          expect(json_response['line_items'].first['variant']).to have_attributes([:images])
        end

        it "lists variants product id" do
          get spree.api_order_path(order)

          expect(json_response['line_items'].first['variant']).to have_attributes([:product_id])
        end

        it "includes the tax_total in the response" do
          get spree.api_order_path(order)

          expect(json_response['included_tax_total']).to eq('0.0')
          expect(json_response['additional_tax_total']).to eq('0.0')
          expect(json_response['display_included_tax_total']).to eq('$0.00')
          expect(json_response['display_additional_tax_total']).to eq('$0.00')
        end

        it "lists line item adjustments" do
          adjustment = create(:adjustment,
            label: "10% off!",
            order: order,
            adjustable: order.line_items.first)
          adjustment.update_column(:amount, 5)
          get spree.api_order_path(order)

          adjustment = json_response['line_items'].first['adjustments'].first
          expect(adjustment['label']).to eq("10% off!")
          expect(adjustment['amount']).to eq("5.0")
        end

        it "lists payments source without gateway info" do
          order.payments.push payment = create(:payment)
          get spree.api_order_path(order)

          source = json_response[:payments].first[:source]
          expect(source[:name]).to eq payment.source.name
          expect(source[:cc_type]).to eq payment.source.cc_type
          expect(source[:last_digits]).to eq payment.source.last_digits
          expect(source[:month]).to eq payment.source.month
          expect(source[:year]).to eq payment.source.year
          expect(source.key?(:gateway_customer_profile_id)).to be false
          expect(source.key?(:gateway_payment_profile_id)).to be false
        end

        context "when in delivery" do
          let!(:shipping_method) do
            FactoryBot.create(:shipping_method).tap do |shipping_method|
              shipping_method.calculator.preferred_amount = 10
              shipping_method.calculator.save
            end
          end

          before do
            order.next!
            order.next!
            order.save
          end

          it "includes the ship_total in the response" do
            get spree.api_order_path(order)

            expect(json_response['ship_total']).to eq '10.0'
            expect(json_response['display_ship_total']).to eq '$10.00'
          end

          it "returns available shipments for an order" do
            get spree.api_order_path(order)
            expect(response.status).to eq(200)
            expect(json_response["shipments"]).not_to be_empty
            shipment = json_response["shipments"][0]
            # Test for correct shipping method attributes
            # Regression test for https://github.com/spree/spree/issues/3206
            expect(shipment["shipping_methods"]).not_to be_nil
            json_shipping_method = shipment["shipping_methods"][0]
            expect(json_shipping_method["id"]).to eq(shipping_method.id)
            expect(json_shipping_method["name"]).to eq(shipping_method.name)
            expect(json_shipping_method["code"]).to eq(shipping_method.code)
            expect(json_shipping_method["zones"]).not_to be_empty
            expect(json_shipping_method["shipping_categories"]).not_to be_empty

            # Test for correct shipping rates attributes
            # Regression test for https://github.com/spree/spree/issues/3206
            expect(shipment["shipping_rates"]).not_to be_nil
            shipping_rate = shipment["shipping_rates"][0]
            expect(shipping_rate["name"]).to eq(json_shipping_method["name"])
            expect(shipping_rate["cost"]).to eq("10.0")
            expect(shipping_rate["selected"]).to be true
            expect(shipping_rate["display_cost"]).to eq("$10.00")
            expect(shipping_rate["shipping_method_code"]).to eq(json_shipping_method["code"])

            expect(shipment["stock_location_name"]).not_to be_blank
            manifest_item = shipment["manifest"][0]
            expect(manifest_item["quantity"]).to eq(1)
            expect(manifest_item["variant_id"]).to eq(order.line_items.first.variant_id)
          end
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      context "with no orders" do
        before { Spree::Order.delete_all }
        it "still returns a root :orders key" do
          get spree.api_orders_path
          expect(json_response["orders"]).to eq([])
        end
      end

      context "caching enabled" do
        before do
          ActionController::Base.perform_caching = true
          3.times { Order.create }
        end

        it "returns unique orders" do
          get spree.api_orders_path

          orders = json_response[:orders]
          expect(orders.count).to be >= 3
          expect(orders.map { |order| order[:id] }).to match_array Order.pluck(:id)
        end

        after { ActionController::Base.perform_caching = false }
      end

      it "lists payments source with gateway info" do
        order.payments.push payment = create(:payment)
        get spree.api_order_path(order)

        source = json_response[:payments].first[:source]
        expect(source[:name]).to eq payment.source.name
        expect(source[:cc_type]).to eq payment.source.cc_type
        expect(source[:last_digits]).to eq payment.source.last_digits
        expect(source[:month]).to eq payment.source.month
        expect(source[:year]).to eq payment.source.year
        expect(source[:gateway_customer_profile_id]).to eq payment.source.gateway_customer_profile_id
        expect(source[:gateway_payment_profile_id]).to eq payment.source.gateway_payment_profile_id
      end

      context "with two orders" do
        before { create(:order) }

        it "can view all orders" do
          get spree.api_orders_path
          expect(json_response["orders"].first).to have_attributes(attributes)
          expect(json_response["count"]).to eq(2)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["pages"]).to eq(1)
        end

        # Test for https://github.com/spree/spree/issues/1763
        it "can control the page size through a parameter" do
          get spree.api_orders_path, params: { per_page: 1 }
          expect(json_response["orders"].count).to eq(1)
          expect(json_response["orders"].first).to have_attributes(attributes)
          expect(json_response["count"]).to eq(1)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["pages"]).to eq(2)
        end
      end

      context "search" do
        before do
          create(:order)
          Spree::Order.last.update_attribute(:email, 'spree@spreecommerce.com')
        end

        let(:expected_result) { Spree::Order.last }

        it "can query the results through a parameter" do
          get spree.api_orders_path, params: { q: { email_cont: 'spree' } }
          expect(json_response["orders"].count).to eq(1)
          expect(json_response["orders"].first).to have_attributes(attributes)
          expect(json_response["orders"].first["email"]).to eq(expected_result.email)
          expect(json_response["count"]).to eq(1)
          expect(json_response["current_page"]).to eq(1)
          expect(json_response["pages"]).to eq(1)
        end
      end

      context "creation" do
        it "can create an order without any parameters" do
          post spree.api_orders_path
          expect(response.status).to eq(201)
          expect(json_response["state"]).to eq("cart")
        end

        it "can arbitrarily set the line items price" do
          post spree.api_orders_path, params: {
            order: {
              line_items: {
                "0" => {
                  price: 33.0, variant_id: variant.to_param, quantity: 5
                }
              }
            }
          }
          expect(response.status).to eq 201
          expect(Order.last.line_items.first.price.to_f).to eq(33.0)
        end

        it "can set the user_id for the order" do
          user = Spree.user_class.create
          post spree.api_orders_path, params: { order: { user_id: user.id } }
          expect(response.status).to eq 201
          expect(json_response["user_id"]).to eq(user.id)
        end

        context "with payment" do
          let(:params) do
            {
              payments: [{
                amount: '10.0',
                payment_method: create(:payment_method).name,
                source: {
                  month: "01",
                  year: Date.today.year.to_s.last(2),
                  cc_type: "123",
                  last_digits: "1111",
                  name: "Credit Card"
                }
              }]
            }
          end

          context "with source" do
            it "creates a payment" do
              post spree.api_orders_path, params: { order: params }
              payment = json_response['payments'].first

              expect(response.status).to eq 201
              expect(payment['amount']).to eql "10.0"
              expect(payment['source']['last_digits']).to eql "1111"
            end

            context "when payment_method is missing" do
              it "returns an error" do
                params[:payments][0].delete(:payment_method)
                post spree.api_orders_path, params: { order: params }
                expect(response.status).to eq 404
              end
            end
          end
        end
      end

      context "updating" do
        it "can set the user_id for the order" do
          user = Spree.user_class.create
          put spree.api_order_path(order), params: { order: { user_id: user.id } }
          expect(response.status).to eq 200
          expect(json_response["user_id"]).to eq(user.id)
        end
      end

      context "can cancel an order" do
        before do
          stub_spree_preferences(mails_from: "spree@example.com")

          order.completed_at = Time.current
          order.state = 'complete'
          order.shipment_state = 'ready'
          order.save!
        end

        specify do
          put spree.cancel_api_order_path(order)
          expect(json_response["state"]).to eq("canceled")
          expect(json_response["canceler_id"]).to eq(current_api_user.id)
        end
      end
    end

    describe '#apply_coupon_code' do
      let(:promo) { create(:promotion_with_item_adjustment, code: 'abc') }
      let(:promo_code) { promo.codes.first }

      before do
        allow_any_instance_of(Order).to receive_messages user: current_api_user
      end

      context 'when successful' do
        let(:order) { create(:order_with_line_items) }

        it 'applies the coupon' do
          expect(Spree::Deprecation).to receive(:warn)

          put spree.apply_coupon_code_api_order_path(order), params: { coupon_code: promo_code.value }

          expect(response.status).to eq 200
          expect(order.reload.promotions).to eq [promo]
          expect(json_response).to eq({
            "success" => I18n.t('spree.coupon_code_applied'),
            "error" => nil,
            "successful" => true,
            "status_code" => "coupon_code_applied"
          })
        end
      end

      context 'when unsuccessful' do
        let(:order) { create(:order) } # no line items to apply the code to

        it 'returns an error' do
          expect(Spree::Deprecation).to receive(:warn)

          put spree.apply_coupon_code_api_order_path(order), params: { coupon_code: promo_code.value }

          expect(response.status).to eq 422
          expect(order.reload.promotions).to eq []
          expect(json_response).to eq({
            "success" => nil,
            "error" => I18n.t('spree.coupon_code_unknown_error'),
            "successful" => false,
            "status_code" => "coupon_code_unknown_error"
          })
        end
      end
    end
  end
end
