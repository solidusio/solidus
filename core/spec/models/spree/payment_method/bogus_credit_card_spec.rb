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

  it "has one of every kind of supported preference type" do
    preference_types = payment_method.preferences.keys
      .map { payment_method.preference_type(_1) }
      .uniq

    supported_preference_types = [
      *Spree::Preferences::PreferableClassMethods::DEFAULT_ADMIN_FORM_PREFERENCE_TYPES,
      :array,
      :hash
    ]

    # To make this class more valuable to developers as a test payment method,
    # it should have at least one of each preference type configured on it.
    expect(preference_types).to contain_exactly(*supported_preference_types)
  end
end
