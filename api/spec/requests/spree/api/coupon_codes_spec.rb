# frozen_string_literal: true

require "spec_helper"

module Spree::Api
  describe "Coupon codes", type: :request do
    let(:current_api_user) do
      user = Spree.user_class.new(email: "solidus@example.com")
      user.generate_spree_api_key!
      user
    end

    before do
      stub_authentication!
      expect(Spree::Config.promotions.coupon_code_handler_class).to receive(:new).and_return(handler)
    end

    describe "#create" do
      before do
        allow_any_instance_of(Spree::Order).to receive_messages user: current_api_user
      end

      context "when successful" do
        let(:order) { create(:order_with_line_items) }
        let(:successful_application) do
          double(
            "handler",
            successful?: true,
            success: "The coupon code was successfully applied to your order.",
            error: nil,
            status_code: "coupon_code_applied"
          )
        end

        let(:handler) do
          double("handler", apply: successful_application)
        end

        it "applies the coupon" do
          post spree.api_order_coupon_codes_path(order), params: {coupon_code: "10OFF"}

          expect(response.status).to eq(200)
          expect(json_response).to eq({
            "success" => "The coupon code was successfully applied to your order.",
            "error" => nil,
            "successful" => true,
            "status_code" => "coupon_code_applied"
          })
        end
      end

      context "when unsuccessful" do
        let(:order) { create(:order) }
        let(:unsuccessful_application) do
          double(
            "handler",
            successful?: false,
            success: nil,
            error: "This coupon code could not be applied to the cart at this time.",
            status_code: "coupon_code_unknown_error"
          )
        end

        let(:handler) do
          double("handler", apply: unsuccessful_application)
        end

        it "returns an error" do
          post spree.api_order_coupon_codes_path(order), params: {coupon_code: "10OFF"}

          expect(response.status).to eq(422)
          expect(json_response).to eq({
            "success" => nil,
            "error" => I18n.t("spree.coupon_code_unknown_error"),
            "successful" => false,
            "status_code" => "coupon_code_unknown_error"
          })
        end
      end
    end

    describe "#destroy" do
      let(:order) { create(:order_with_line_items, user: current_api_user) }

      subject do
        delete spree.api_order_coupon_code_path(order, "10OFF")
      end

      context "when successful" do
        let(:successful_removal) do
          double(
            "handler",
            successful?: true,
            success: "The coupon code was successfully removed from this order.",
            error: nil,
            status_code: "coupon_code_removed"
          )
        end

        let(:handler) do
          double("handler", remove: successful_removal)
        end

        it "removes the coupon" do
          subject
          expect(response.status).to eq(200)
          expect(json_response).to eq({
            "success" => I18n.t("spree.coupon_code_removed"),
            "error" => nil,
            "successful" => true,
            "status_code" => "coupon_code_removed"
          })
        end
      end

      context "when unsuccessful" do
        let(:unsuccessful_removal) do
          double(
            "handler",
            successful?: false,
            success: nil,
            error: "The coupon code you are trying to remove is not present on this order.",
            status_code: "coupon_code_not_present"
          )
        end

        let(:handler) do
          double("handler", remove: unsuccessful_removal)
        end

        it "returns an error" do
          subject

          expect(response.status).to eq(422)
          expect(json_response).to eq({
            "success" => nil,
            "error" => I18n.t("spree.coupon_code_not_present"),
            "successful" => false,
            "status_code" => "coupon_code_not_present"
          })
        end
      end
    end
  end
end
