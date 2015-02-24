require 'spec_helper'

module Spree
  describe Api::CheckoutsController do
    render_views

    before(:each) do
      stub_authentication!
      Spree::Config[:track_inventory_levels] = false
      country_zone = create(:zone, :name => 'CountryZone')
      @state = create(:state)
      @country = @state.country
      country_zone.members.create(:zoneable => @country)
      create(:stock_location)

      @shipping_method = create(:shipping_method, :zones => [country_zone])
      @payment_method = create(:credit_card_payment_method)
    end

    after do
      Spree::Config[:track_inventory_levels] = true
    end

    context "PUT 'next'" do
      let!(:order) { create(:order_with_line_items) }
      it "cannot transition to address without a line item" do
        order.line_items.delete_all
        order.update_column(:email, "spree@example.com")
        api_put :next, :id => order.to_param, :order_token => order.token
        response.status.should == 422
        json_response["errors"]["base"].should include(Spree.t(:there_are_no_items_for_this_order))
      end

      it "can transition an order to the next state" do
        order.update_column(:email, "spree@example.com")

        api_put :next, :id => order.to_param, :order_token => order.token
        response.status.should == 200
        json_response['state'].should == 'address'
      end

      it "cannot transition if order email is blank" do
        order.update_columns(
          state: 'address',
          email: nil
        )

        api_put :next, :id => order.to_param, :order_token => order.token
        response.status.should == 422
        json_response['error'].should =~ /could not be transitioned/
      end

      context 'insufficient stock' do
        before do
          expect_any_instance_of(Spree::Order).to receive(:next!).and_raise(Spree::LineItem::InsufficientStock)
        end

        subject { api_put :next, :id => order.to_param, :order_token => order.token }

        it "should return a 422" do
          expect(subject.status).to eq(422)
        end

        it "returns an error message" do
          subject
          expect(JSON.parse(response.body)).to eq(
            {"errors" => ["Quantity is not available for items in your order"], "type" => "insufficient_stock"}
          )
        end
      end
    end

    context "PUT 'complete'" do
      context "with order in confirm state" do
        subject do
          api_put :complete, params
        end

        let(:params) { {id: order.to_param, order_token: order.token} }
        let(:order) { create(:order_with_line_items) }

        before do
          order.update_column(:state, "confirm")
        end

        it "can transition from confirm to complete" do
          Spree::Order.any_instance.stub(:payment_required? => false)
          subject
          json_response['state'].should == 'complete'
          response.status.should == 200
        end

        it "returns a sensible error when no payment method is specified" do
          # api_put :complete, :id => order.to_param, :order_token => order.token, :order => {}
          subject
          json_response["errors"]["base"].should include(Spree.t(:no_pending_payments))
        end

        context "with mismatched expected_total" do
          let(:params) { super().merge(expected_total: order.total + 1) }

          it "returns an error if expected_total is present and does not match actual total" do
            # api_put :complete, :id => order.to_param, :order_token => order.token, :expected_total => order.total + 1
            subject
            response.status.should == 400
            json_response['errors']['expected_total'].should include(Spree.t(:expected_total_mismatch, :scope => 'api.order'))
          end
        end
      end
    end

    context "PUT 'advance'" do
      let!(:order) { create(:order_with_line_items) }
      it 'continues to advance advances an order while it can move forward' do
        Spree::Order.any_instance.should_receive(:next).exactly(3).times.and_return(true, true, false)
        api_put :advance, :id => order.to_param, :order_token => order.token
      end
      it 'returns the order' do
        api_put :advance, :id => order.to_param, :order_token => order.token
        json_response['id'].should == order.id
      end

    end
  end
end
