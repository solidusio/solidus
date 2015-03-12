require 'spec_helper'
require 'email_spec'

describe Spree::CartonMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:carton) { create(:carton) }

  context ":from not set explicitly" do
    it "falls back to spree config" do
      message = Spree::CartonMailer.shipped_email(carton.id)
      message.from.should == [Spree::Config[:mails_from]]
    end
  end

  # Regression test for #2196
  it "doesn't include out of stock in the email body" do
    shipment_email = Spree::CartonMailer.shipped_email(carton.id)
    shipment_email.body.should_not include(%Q{Out of Stock})
  end

  context "with resend option" do
    subject do
      Spree::CartonMailer.shipped_email(carton.id, resend: true).subject
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
          shipped_email = Spree::CartonMailer.shipped_email(carton.id)
          shipped_email.body.should include("Caro Cliente,")
        end
      end
    end
  end
end
