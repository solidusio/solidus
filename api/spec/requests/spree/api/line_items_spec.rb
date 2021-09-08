# frozen_string_literal: true

require 'spec_helper'

module Spree
  PermittedAttributes.module_eval do
    mattr_writer :line_item_attributes
  end

  unless PermittedAttributes.line_item_attributes.include? :options
    PermittedAttributes.line_item_attributes << { options: [:some_option] }
  end

  describe Api::LineItemsController, type: :request do
    let!(:order) { create(:order_with_line_items, line_items_count: 1) }

    let(:product) { create(:product) }
    let(:attributes) { [:id, :quantity, :price, :variant, :total, :display_amount, :single_display_amount] }
    let(:resource_scoping) { { order_id: order.to_param } }

    before do
      stub_authentication!
    end

    it "can learn how to create a new line item" do
      get spree.new_api_order_line_item_path(order)
      expect(json_response["attributes"]).to eq(["quantity", "price", "variant_id"])
      required_attributes = json_response["required_attributes"]
      expect(required_attributes).to include("quantity", "variant_id")
    end

    context "authenticating with a token" do
      it "can add a new line item to an existing order" do
        post spree.api_order_line_items_path(order), params: { line_item: { variant_id: product.master.to_param, quantity: 1 }, order_token: order.guest_token }
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["variant"]["name"]).not_to be_blank
      end

      it "can add a new line item to an existing order with token in header" do
        post spree.api_order_line_items_path(order),
          params: { line_item: { variant_id: product.master.to_param, quantity: 1 } },
          headers: { 'X-Spree-Order-Token' => order.guest_token }
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["variant"]["name"]).not_to be_blank
      end
    end

    context "as the order owner" do
      before do
        allow_any_instance_of(Order).to receive_messages user: current_api_user
      end

      context "dealing with a completed order" do
        let!(:order) { create(:completed_order_with_totals) }

        it "can't add a new line item" do
          post spree.api_order_line_items_path(order), params: { line_item: { variant_id: product.master.to_param, quantity: 1 } }
          assert_unauthorized!
        end

        it "can't update a line item" do
          line_item = order.line_items.first
          put spree.api_order_line_item_path(order, line_item), params: { line_item: { quantity: 10 } }
          assert_unauthorized!
        end

        it "can't delete a line item" do
          line_item = order.line_items.first
          delete spree.api_order_line_item_path(order, line_item)
          assert_unauthorized!
        end
      end

      it "can add a new line item to an existing order" do
        post spree.api_order_line_items_path(order), params: { line_item: { variant_id: product.master.to_param, quantity: 1 } }
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response["variant"]["name"]).not_to be_blank
      end

      it "can add a new line item to an existing order with options" do
        without_partial_double_verification do
          expect_any_instance_of(LineItem).to receive(:some_option=).with("foobar")
        end
        post spree.api_order_line_items_path(order),
                 params: {
                                    line_item: {
                              variant_id: product.master.to_param,
                              quantity: 1,
                              options: { some_option: "foobar" }
                            }
        }
        expect(response.status).to eq(201)
      end

      it "default quantity to 1 if none is given" do
        post spree.api_order_line_items_path(order), params: { line_item: { variant_id: product.master.to_param } }
        expect(response.status).to eq(201)
        expect(json_response).to have_attributes(attributes)
        expect(json_response[:quantity]).to eq 1
      end

      it "increases a line item's quantity if it exists already" do
        order.line_items.create(variant_id: product.master.id, quantity: 10)
        post spree.api_order_line_items_path(order), params: { line_item: { variant_id: product.master.to_param, quantity: 1 } }
        expect(response.status).to eq(201)
        order.reload
        expect(order.line_items.count).to eq(2) # 1 original due to factory, + 1 in this test
        expect(json_response).to have_attributes(attributes)
        expect(json_response["quantity"]).to eq(11)
      end

      it "can update a line item on the order" do
        line_item = order.line_items.first
        put spree.api_order_line_item_path(order, line_item), params: { line_item: { quantity: 101 } }
        expect(response.status).to eq(200)
        order.reload
        expect(order.total).to eq(1010) # 10 original due to factory, + 1000 in this test
        expect(json_response).to have_attributes(attributes)
        expect(json_response["quantity"]).to eq(101)
      end

      it "can update a line item's options on the order" do
        without_partial_double_verification do
          expect_any_instance_of(LineItem).to receive(:some_option=).with("foobar")
        end
        line_item = order.line_items.first
        put spree.api_order_line_item_path(order, line_item),
                params: {
                  line_item: { quantity: 1, options: { some_option: "foobar" } }
                }
        expect(response.status).to eq(200)
      end

      it "can delete a line item on the order" do
        line_item = order.line_items.first
        delete spree.api_order_line_item_path(order, line_item)
        expect(response.status).to eq(204)
        order.reload
        expect(order.line_items.count).to eq(0) # 1 original due to factory, - 1 in this test
        expect { line_item.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "order contents changed after shipments were created" do
        let!(:store) { create(:store) }
        let!(:order) { Order.create(store: store) }
        let!(:line_item) { order.contents.add(product.master) }

        before { order.create_proposed_shipments }

        it "clear out shipments on create" do
          expect(order.reload.shipments).not_to be_empty
          post spree.api_order_line_items_path(order), params: { line_item: { variant_id: product.master.to_param, quantity: 1 } }
          expect(order.reload.shipments).to be_empty
        end

        it "clear out shipments on update" do
          expect(order.reload.shipments).not_to be_empty
          put spree.api_order_line_item_path(order, line_item), params: { line_item: { quantity: 1000 } }
          expect(order.reload.shipments).to be_empty
        end

        it "clear out shipments on delete" do
          expect(order.reload.shipments).not_to be_empty
          delete spree.api_order_line_item_path(order, line_item)
          expect(order.reload.shipments).to be_empty
        end

        context "order is completed" do
          before do
            allow(order).to receive_messages completed?: true
            allow(Order).to receive_message_chain :includes, find_by!: order
          end

          it "doesn't destroy shipments or restart checkout flow" do
            expect(order.reload.shipments).not_to be_empty
            post spree.api_order_line_items_path(order), params: { line_item: { variant_id: product.master.to_param, quantity: 1 } }
            expect(order.reload.shipments).not_to be_empty
          end
        end
      end
    end

    context "as just another user" do
      before do
        user = create(:user)
        allow(Spree.user_class).to receive(:find_by).
                                     and_return(user)
      end

      it "cannot add a new line item to the order" do
        post spree.api_order_line_items_path(order), params: { line_item: { variant_id: product.master.to_param, quantity: 1 } }
        assert_unauthorized!
      end

      it "cannot update a line item on the order" do
        line_item = order.line_items.first
        put spree.api_order_line_item_path(order, line_item), params: { line_item: { quantity: 1000 } }
        assert_unauthorized!
        expect(line_item.reload.quantity).not_to eq(1000)
      end

      it "cannot delete a line item on the order" do
        line_item = order.line_items.first
        delete spree.api_order_line_item_path(order, line_item)
        assert_unauthorized!
        expect { line_item.reload }.not_to raise_error
      end
    end
  end
end
