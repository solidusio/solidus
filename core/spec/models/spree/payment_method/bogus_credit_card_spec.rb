# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PaymentMethod::BogusCreditCard, type: :model do
  let(:payment_method) { create :credit_card_payment_method }

  it "works as a payment method with a payment source" do
    expect {
      create :credit_card,
        payment_method:,
        gateway_customer_profile_id: "BGS-RERTERT"
    }.not_to raise_error
  end
end
