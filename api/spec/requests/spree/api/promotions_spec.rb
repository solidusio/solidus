# frozen_string_literal: true

require "spec_helper"
require "ostruct"

module Spree::Api
  describe "Promotions", type: :request do
    shared_examples "a JSON response" do
      it "should be ok" do
        subject
        expect(response).to be_ok
      end

      it "should return JSON" do
        subject
        payload = HashWithIndifferentAccess.new(JSON.parse(response.body))
        expect(payload).to_not be_nil
        Spree::Api::Config.promotion_attributes.each do |attribute|
          expect(payload).to be_has_key(attribute)
        end
      end
    end

    before do
      stub_authentication!
    end

    let(:found_promotion) do
      ::OpenStruct.new(
        id: 1,
        name: "Test Promotion",
        description: "Promotion for testing purposes",
        path: "/api/promotions/test-promo",
        starts_at: 1.day.ago,
        expires_at: 1.day.from_now,
        type: "something",
        usage_limit: 100,
        advertise: false
      )
    end

    describe "GET #show" do
      subject { get spree.api_promotion_path("1") }

      context "when admin" do
        sign_in_as_admin!

        context "when finding by a promotion" do
          before do
            allow(Spree::Config.promotions.promotion_finder_class).to receive(:by_code_or_id).and_return(found_promotion)
          end

          it_behaves_like "a JSON response"
        end

        context "when id does not exist" do
          before do
            allow(Spree::Config.promotions.promotion_finder_class).to receive(:by_code_or_id).and_raise(ActiveRecord::RecordNotFound)
          end

          it "should be 404" do
            subject
            expect(response.status).to eq(404)
          end
        end
      end

      context "when non admin" do
        before do
          allow(Spree::Config.promotions.promotion_finder_class).to receive(:by_code_or_id).and_return(found_promotion)
        end

        it "should be unauthorized" do
          subject
          assert_unauthorized!
        end
      end
    end
  end
end
