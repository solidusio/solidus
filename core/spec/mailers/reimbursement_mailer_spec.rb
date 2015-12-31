require 'spec_helper'
require 'email_spec'

describe Solidus::ReimbursementMailer, :type => :mailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:reimbursement) { create(:reimbursement) }

  it "accepts a reimbursement id as an alternative to a Reimbursement object" do
    expect(Solidus::Reimbursement).to receive(:find).with(reimbursement.id).and_return(reimbursement)

    Solidus::ReimbursementMailer.reimbursement_email(reimbursement.id).body
  end

  context "emails must be translatable" do
    context "reimbursement_email" do
      context "pt-BR locale" do
        before do
          I18n.enforce_available_locales = false
          pt_br_shipped_email = { :spree => { :reimbursement_mailer => { :reimbursement_email => { :dear_customer => 'Caro Cliente,' } } } }
          I18n.backend.store_translations :'pt-BR', pt_br_shipped_email
          I18n.locale = :'pt-BR'
        end

        after do
          I18n.locale = I18n.default_locale
          I18n.enforce_available_locales = true
        end

        specify do
          reimbursement_email = Solidus::ReimbursementMailer.reimbursement_email(reimbursement)
          expect(reimbursement_email.body).to include("Caro Cliente,")
        end
      end
    end
  end
end
