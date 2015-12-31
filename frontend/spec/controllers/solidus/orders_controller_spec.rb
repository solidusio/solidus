require 'spec_helper'

describe Solidus::OrdersController, :type => :controller do
  let(:user) { create(:user) }

  context "Order model mock" do
    let(:order) do
      Solidus::Order.create!
    end
    let(:variant) { create(:variant) }

    before do
      allow(controller).to receive_messages(:try_solidus_current_user => user)
    end

    context "#populate" do
      it "should create a new order when none specified" do
        solidus_post :populate, {}, {}
        expect(cookies.signed[:guest_token]).not_to be_blank
        expect(Solidus::Order.find_by_guest_token(cookies.signed[:guest_token])).to be_persisted
      end

      context "with Variant" do
        it "should handle population" do
          expect do
            solidus_post :populate, variant_id: variant.id, quantity: 5
          end.to change { user.orders.count }.by(1)
          order = user.orders.last
          expect(response).to redirect_to solidus.cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(5)
        end

        it "shows an error when population fails" do
          request.env["HTTP_REFERER"] = solidus.root_path
          allow_any_instance_of(Solidus::LineItem).to(
            receive(:valid?).and_return(false)
          )
          allow_any_instance_of(Solidus::LineItem).to(
            receive_message_chain(:errors, :full_messages).
              and_return(["Order population failed"])
          )

          solidus_post :populate, variant_id: variant.id, quantity: 5

          expect(response).to redirect_to(solidus.root_path)
          expect(flash[:error]).to eq("Order population failed")
        end

        it "shows an error when quantity is invalid" do
          request.env["HTTP_REFERER"] = solidus.root_path

          solidus_post(
            :populate,
            variant_id: variant.id, quantity: -1
          )

          expect(response).to redirect_to(solidus.root_path)
          expect(flash[:error]).to eq(
            Solidus.t(:please_enter_reasonable_quantity)
          )
        end
      end
    end

    context "#update" do
      context "with authorization" do
        before do
          allow(controller).to receive :check_authorization
          allow(controller).to receive_messages current_order: order
        end

        it "should render the edit view (on failure)" do
          # email validation is only after address state
          order.update_column(:state, "delivery")
          solidus_put :update, { :order => { :email => "" } }, { :order_id => order.id }
          expect(response).to render_template :edit
        end

        it "should redirect to cart path (on success)" do
          allow(order).to receive(:update_attributes).and_return true
          solidus_put :update, {}, {:order_id => 1}
          expect(response).to redirect_to(solidus.cart_path)
        end
      end
    end

    context "#empty" do
      before do
        allow(controller).to receive :check_authorization
      end

      it "should destroy line items in the current order" do
        allow(controller).to receive(:current_order).and_return(order)
        expect(order).to receive(:empty!)
        solidus_put :empty
        expect(response).to redirect_to(solidus.cart_path)
      end
    end

    # Regression test for #2750
    context "#update" do
      before do
        allow(user).to receive :last_incomplete_solidus_order
        allow(controller).to receive :set_current_order
      end

      it "cannot update a blank order" do
        solidus_put :update, :order => { :email => "foo" }
        expect(flash[:error]).to eq(Solidus.t(:order_not_found))
        expect(response).to redirect_to(solidus.root_path)
      end
    end
  end

  context "line items quantity is 0" do
    let(:order) { Solidus::Order.create }
    let(:variant) { create(:variant) }
    let!(:line_item) { order.contents.add(variant, 1) }

    before do
      allow(controller).to receive(:check_authorization)
      allow(controller).to receive_messages(:current_order => order)
    end

    it "removes line items on update" do
      expect(order.line_items.count).to eq 1
      solidus_put :update, :order => { line_items_attributes: { "0" => { id: line_item.id, quantity: 0 } } }
      expect(order.reload.line_items.count).to eq 0
    end
  end
end
