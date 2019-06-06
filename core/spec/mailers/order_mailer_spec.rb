# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderMailer, type: :mailer do
  let(:order) do
    order = create(:order)
    product = stub_model(Spree::Product, name: %{The "BEST" product})
    variant = stub_model(Spree::Variant, product: product)
    price = stub_model(Spree::Price, variant: variant, amount: 5.00)
    store = FactoryBot.build :store, mail_from_address: "store@example.com"
    line_item = stub_model(Spree::LineItem, variant: variant, order: order, quantity: 1, price: 4.99)
    allow(variant).to receive_messages(default_price: price)
    allow(order).to receive_messages(line_items: [line_item])
    allow(order).to receive(:store).and_return(store)
    order
  end

  it "uses the order's store for the from address" do
    message = Spree::OrderMailer.confirm_email(order)
    expect(message.from).to eq ["store@example.com"]
  end

  it "doesn't aggressively escape double quotes in confirmation body" do
    confirmation_email = Spree::OrderMailer.confirm_email(order)
    expect(confirmation_email.body).not_to include("&quot;")
  end

  context "only shows eligible adjustments in emails" do
    before do
      create(
        :adjustment,
        adjustable: order,
        order:      order,
        eligible:   true,
        label:      'Eligible Adjustment'
      )

      create(
        :adjustment,
        adjustable: order,
        order:      order,
        eligible:   false,
        label:      'Ineligible Adjustment'
      )
    end

    let!(:confirmation_email) { Spree::OrderMailer.confirm_email(order) }
    let!(:cancel_email) { Spree::OrderMailer.cancel_email(order) }

    specify do
      expect(confirmation_email.body).not_to include("Ineligible Adjustment")
    end

    specify do
      expect(cancel_email.body).not_to include("Ineligible Adjustment")
    end
  end

  context "displays unit costs from line item" do
    # Regression test for https://github.com/spree/spree/issues/2772

    # Tests mailer view spree/order_mailer/confirm_email.text.erb
    specify do
      confirmation_email = Spree::OrderMailer.confirm_email(order)
      expect(confirmation_email.parts.first.body).to include("4.99")
      expect(confirmation_email.parts.first.body).to_not include("5.00")
    end

    # Tests mailer view spree/order_mailer/cancel_email.text.erb
    specify do
      cancel_email = Spree::OrderMailer.cancel_email(order)
      expect(cancel_email.parts.first.body).to include("4.99")
      expect(cancel_email.parts.first.body).to_not include("5.00")
    end
  end

  context "emails must be translatable" do
    context "pt-BR locale" do
      before do
        I18n.enforce_available_locales = false
        pt_br_confirm_mail = { spree: { order_mailer: { confirm_email: { dear_customer: 'Caro Cliente,' } } } }
        pt_br_cancel_mail = { spree: { order_mailer: { cancel_email: { order_summary_canceled: 'Resumo da Pedido [CANCELADA]' } } } }
        I18n.backend.store_translations :'pt-BR', pt_br_confirm_mail
        I18n.backend.store_translations :'pt-BR', pt_br_cancel_mail
        I18n.locale = :'pt-BR'
      end

      after do
        I18n.locale = I18n.default_locale
        I18n.enforce_available_locales = true
      end

      context "confirm_email" do
        specify do
          confirmation_email = Spree::OrderMailer.confirm_email(order)
          expect(confirmation_email.parts.first.body).to include("Caro Cliente,")
        end
      end

      context "cancel_email" do
        specify do
          cancel_email = Spree::OrderMailer.cancel_email(order)
          expect(cancel_email.parts.first.body).to include("Resumo da Pedido [CANCELADA]")
        end
      end
    end
  end

  context "with preference :send_core_emails set to false" do
    it "sends no email" do
      stub_spree_preferences(send_core_emails: false)
      message = Spree::OrderMailer.confirm_email(order)
      expect(message.body).to be_blank
    end
  end
end
