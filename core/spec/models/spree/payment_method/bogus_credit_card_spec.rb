# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe PaymentMethod::BogusCreditCard, type: :model do
    let(:bogus) { create(:credit_card_payment_method) }
    let!(:cc) { create(:credit_card, payment_method: bogus, gateway_customer_profile_id: "BGS-RERTERT") }
  end
end
