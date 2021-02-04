# frozen_string_literal: true

require "rails_helper"

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
        let(:user) {
          Spree::LegacyUser.create! email: "foo.@example.com", password: "password", password_confirmation: "password"
        }
        let(:order) {
          order = Spree::Order.new
          order.associate_user! user

          order
        }
        context "when DEVISE is defined" do
          before {
            # this is the default email_regexp as seen in https://github.com/heartcombo/devise/blob/master/lib/devise.rb#L116
            stub_const "Devise", double("Devise", email_regexp: /\A[^@\s]+@[^@\s]+\z/)
          }

          it "will validate the email against its email_regexp configuration" do
            order.valid?

            expect(order.errors[:email]).to be_blank
          end
        end

        context "when DEVISE is not defined" do
          it "will include an email validation error if email doesn't follow spree/email format" do
            order.valid?

            expect(order.errors[:email]).to include("is invalid")
          end
        end
      end
    end
  end
end
