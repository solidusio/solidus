require 'spec_helper'

describe Spree::OrdersController do
  let(:user) { create(:user) }

  context "Order model mock" do
    let(:order) do
      Spree::Order.create!
    end
    let(:variant) { create(:variant) }

    before do
      controller.stub(:try_spree_current_user => user)
    end

    context "#populate" do
      it "should create a new order when none specified" do
        spree_post :populate, {}, {}
        session[:order_id].should_not be_blank
        Spree::Order.find(session[:order_id]).should be_persisted
      end

      context "with Variant" do
        it "should handle population" do
          expect do
            spree_post :populate, variant_id: variant.id, quantity: 5
          end.to change { user.orders.count }.by(1)
          order = user.orders.last
          expect(response).to redirect_to spree.cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(5)
        end

        it "shows an error when population fails" do
          request.env["HTTP_REFERER"] = spree.root_path
          allow_any_instance_of(Spree::LineItem).to(
            receive(:valid?).and_return(false)
          )
          allow_any_instance_of(Spree::LineItem).to(
            receive_message_chain(:errors, :full_messages).
              and_return(["Order population failed"])
          )

          spree_post :populate, variant_id: variant.id, quantity: 5

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq("Order population failed")
        end

        it "shows an error when quantity is invalid" do
          request.env["HTTP_REFERER"] = spree.root_path

          spree_post(
            :populate,
            variant_id: variant.id, quantity: -1
          )

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq(
            Spree.t(:please_enter_reasonable_quantity)
          )
        end
      end
    end

    context "#update" do
      context "with authorization" do
        before do
          controller.stub :check_authorization
        end

        it "should render the edit view (on failure)" do
          # email validation is only after address state
          order.update_column(:state, "delivery")
          spree_put :update, { :order => { :email => "" } }, {:order_id => order.id }
          response.should render_template :edit
        end

        it "should redirect to cart path (on success)" do
          controller.stub current_order: order
          order.stub(:update_attributes).and_return true
          spree_put :update, {}, {:order_id => 1}
          response.should redirect_to(spree.cart_path)
        end
      end
    end

    context "#empty" do
      before do
        controller.stub :check_authorization
      end

      it "should destroy line items in the current order" do
        controller.stub(:current_order).and_return(order)
        order.contents.should_receive(:empty)
        spree_put :empty
        response.should redirect_to(spree.cart_path)
      end
    end

    # Regression test for #2750
    context "#update" do
      before do
        user.stub :last_incomplete_spree_order
        controller.stub :set_current_order
      end

      it "cannot update a blank order" do
        spree_put :update, :order => { :email => "foo" }
        flash[:error].should == Spree.t(:order_not_found)
        response.should redirect_to(spree.root_path)
      end
    end
  end

  context "line items quantity is 0" do
    let(:order) { Spree::Order.create }
    let(:variant) { create(:variant) }
    let!(:line_item) { order.contents.add(variant, 1) }

    before do
      controller.stub(:check_authorization)
      controller.stub(:current_order => order)
    end

    it "removes line items on update" do
      expect(order.line_items.count).to eq 1
      spree_put :update, :order => { line_items_attributes: { "0" => { id: line_item.id, quantity: 0 } } }
      expect(order.reload.line_items.count).to eq 0
    end
  end
end
