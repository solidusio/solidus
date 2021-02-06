# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Spree::Order, type: :model do
    context "validations" do
      # Regression test for https://github.com/spree/spree/issues/2214
      it "does not return two error messages when email is blank" do
        order = Spree::Order.new
        allow(order).to receive_messages(require_email: true)
        order.valid?
        expect(order.errors[:email]).to eq(["can't be blank"])
      end

      context "email validations where email is copied from user" do
        context "when associated user class has email format validation" do
          test_order_class = Class.new(Spree::Order) do
            belongs_to :user, class_name: "::TestUser", optional: true
          end

          test_user_class = Class.new(Spree::LegacyUser) do
            # same validation as Devise's default email_regexp, used in spree_auth_devise
            validates_format_of :email, with: /\A[^@\s]+@[^@\s]+\z/, allow_blank: true, if: :will_save_change_to_email?
          end

          before {
            stub_const "TestUser", test_user_class
            stub_const "TestOrder", test_order_class
          }

          let(:user) {
            # we could add more test cases for other invalid email formats here
            ::TestUser.create! email: "foo.@example.com", password: "password", password_confirmation: "password"
          }

          let(:order) {
            order = ::TestOrder.new
            order.associate_user! user

            order
          }

          it "will validate the email against the user format validator" do
            order.valid?

            expect(order.errors[:email]).to be_blank
          end
        end

        context "when associated user class does not have email format validation" do
          let(:user) {
            Spree.user_class.create! email: "foo.@example.com", password: "password", password_confirmation: "password"
          }
          let(:order) {
            order = Spree::Order.new
            order.associate_user! user

            order
          }

          it "will include an email validation error if email doesn't follow the standard spree/email format" do
            order.valid?

            expect(order.errors[:email]).to include("is invalid")
          end
        end
      end
    end
  end
end
