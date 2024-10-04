# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderMailer, type: :mailer do
  let(:order) do
    order = create(:order)
    product = stub_model(Spree::Product, name: %{The "BEST" product})
    variant = stub_model(Spree::Variant, product:)
    price = stub_model(Spree::Price, variant:, amount: 5.00)
    store = FactoryBot.build :store, mail_from_address: "store@example.com", bcc_email: "bcc@example.com"
    line_item = stub_model(Spree::LineItem, variant:, order:, quantity: 1, price: 4.99)
    allow(variant).to receive_messages(default_price: price)
    allow(order).to receive_messages(line_items: [line_item])
    allow(order).to receive(:store).and_return(store)
    order
  end

  context "only shows eligible adjustments in emails" do
    before do
      create(
        :adjustment,
        adjustable: order,
        order:,
        eligible:   true,
        label:      'Eligible Adjustment'
      )

      create(
        :adjustment,
        adjustable: order,
        order:,
        eligible:   false,
        label:      'Ineligible Adjustment'
      )
    end

    let!(:confirmation_email) { Spree::OrderMailer.confirm_email(order) }
    let!(:cancel_email) { Spree::OrderMailer.cancel_email(order) }

    specify do
      expect(confirmation_email.parts.first.body).to include("Eligible Adjustment")
      expect(confirmation_email.parts.first.body).not_to include("Ineligible Adjustment")
    end

    specify do
      expect(cancel_email.parts.first.body).to include("Eligible Adjustment")
      expect(cancel_email.parts.first.body).not_to include("Ineligible Adjustment")
    end
  end
end
