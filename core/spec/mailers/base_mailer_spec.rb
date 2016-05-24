require 'spec_helper'
require 'email_spec'

describe Spree::OrderMailer, type: :mailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  context "preference :send_core_emails" do
    let(:carton) { create(:carton) }
    let(:order) { carton.orders.first }

    shared_examples "sent mail" do
      it "sends email" do
        expect(subject.message).not_to be_kind_of(ActionMailer::Base::NullMail)
        expect(subject.body.present? || (subject.parts && subject.parts.all?(&:present?)))
      end
    end

    shared_examples "not sent mail" do
      it "does not send email" do
        expect(subject.message).to be_kind_of(ActionMailer::Base::NullMail)
        expect(subject.body.blank? && subject.parts.nil? || (subject.parts.present? && subject.parts.all?(&:blank?)))
      end
    end

    context "with default preference :send_core_emails" do
      subject { Spree::OrderMailer.confirm_email(order) }
      it_behaves_like 'sent mail'
    end

    context "with preference :send_core_emails set to false" do
      before do
        Spree::Config.send_core_emails = false
      end
      subject { Spree::OrderMailer.confirm_email(order) }
      it_behaves_like 'not sent mail'
    end

    context "with preference :send_core_emails :only" do
      before do
        Spree::Config.send_core_emails = { only: ['OrderMailer'] }
      end
      let(:carton) { create(:carton) }
      describe "with a mailer listed" do
        subject { Spree::OrderMailer.confirm_email(order) }
        it_behaves_like 'sent mail'
      end
      describe 'with a mailer not listed' do
        subject { Spree::CartonMailer.shipped_email(order: order, carton: carton) }
        it_behaves_like 'not sent mail'
      end
    end

    context "with preference :send_core_emails :except" do
      before do
        Spree::Config.send_core_emails = { except: ['OrderMailer'] }
      end
      let(:carton) { create(:carton) }
      describe "with a mailer listed" do
        subject { Spree::OrderMailer.confirm_email(order) }
        it_behaves_like 'not sent mail'
      end
      describe "with a mailer not listed" do
        subject { Spree::CartonMailer.shipped_email(order: order, carton: carton) }
        it_behaves_like 'sent mail'
      end
    end
  end
end
