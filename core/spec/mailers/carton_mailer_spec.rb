require 'spec_helper'
require 'email_spec'

describe Solidus::CartonMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:carton) { create(:carton) }
  let(:order) { carton.orders.first }

  # Regression test for #2196
  it "doesn't include out of stock in the email body" do
    shipment_email = Solidus::CartonMailer.shipped_email(order: order, carton: carton)
    expect(shipment_email.body).not_to include(%Q{Out of Stock})
    expect(shipment_email.body).to include(%Q{Your order has been shipped})
    expect(shipment_email.subject).to eq "#{order.store.name} Shipment Notification ##{order.number}"
  end

  context "deprecated signature" do
    it do
      ActiveSupport::Deprecation.silence do
        mail = Solidus::CartonMailer.shipped_email(carton.id)
        expect(mail.subject).to include "Shipment Notification"
      end
    end
  end

  context "with resend option" do
    subject do
      Solidus::CartonMailer.shipped_email(order: order, carton: carton, resend: true).subject
    end
    it { is_expected.to match /^\[RESEND\] / }
  end

  context "emails must be translatable" do
    context "shipped_email" do
      context "pt-BR locale" do
        before do
          pt_br_shipped_email = { :spree => { :shipment_mailer => { :shipped_email => { :dear_customer => 'Caro Cliente,' } } } }
          I18n.backend.store_translations :'pt-BR', pt_br_shipped_email
          I18n.locale = :'pt-BR'
        end

        after do
          I18n.locale = I18n.default_locale
        end

        specify do
          shipped_email = Solidus::CartonMailer.shipped_email(order: order, carton: carton)
          expect(shipped_email.body).to include("Caro Cliente,")
        end
      end
    end
  end
end
