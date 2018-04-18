# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Events::Processors::MailProcessor do
  let(:processor) { Spree::Events::Processors::MailProcessor }
  let(:order) { create(:order) }

  RSpec.shared_examples 'sends the correct email' do |method|
    it 'sends the email' do
      mail_double = double
      expect(mailer).to receive(method).with(*args).and_return(mail_double)
      expect(mail_double).to receive(:deliver_later)
      subject
    end
  end

  describe '#send_confirm_email' do
    let(:event) { Spree::Events::OrderConfirmedEvent.new(order_id: order.id) }
    subject { processor.send_confirm_email(event) }

    include_examples 'sends the correct email', :confirm_email do
      let(:mailer) { Spree::OrderMailer }
      let(:args) { [order] }
    end

    it 'sets confirmation delivered' do
      expect(order.confirmation_delivered?).to be false
      subject
      expect(Spree::Order.find(order.id).confirmation_delivered?).to be true
    end

    context 'confirmation email has already been sent' do
      before { order.update_column(:confirmation_delivered, true) }

      it 'does not send duplicate confirmation emails' do
        expect(Spree::OrderMailer).not_to receive(:confirm_email)
        subject
      end
    end
  end

  describe '#send_cancel_email' do
    let(:event) { Spree::Events::OrderCancelledEvent.new(order_id: order.id) }
    subject { processor.send_cancel_email(event) }

    include_examples 'sends the correct email', :cancel_email do
      let(:mailer) { Spree::OrderMailer }
      let(:args) { [order] }
    end
  end

  describe '#send_inventory_cancellation_email' do
    let(:inventory_unit_ids) { [] }
    let(:event) { Spree::Events::OrderInventoryCancelledEvent.new(order_id: order.id, inventory_unit_ids: inventory_unit_ids) }
    subject { processor.send_inventory_cancellation_email(event) }

    include_examples 'sends the correct email', :inventory_cancellation_email do
      let(:mailer) { Spree::OrderMailer }
      let(:args) { [order, inventory_unit_ids] }
    end
  end

  describe '#send_reimbursement_email' do
    let(:reimbursement) { create(:reimbursement) }
    let(:event) { Spree::Events::ReimbursementProcessedEvent.new(reimbursement_id: reimbursement.id) }
    subject { processor.send_reimbursement_email(event) }

    include_examples 'sends the correct email', :reimbursement_email do
      let(:mailer) { Spree::ReimbursementMailer }
      let(:args) { [reimbursement] }
    end
  end

  describe '#send_carton_shipped_emails' do
    let(:carton) { create(:carton) }
    let(:event) { Spree::Events::CartonShippedEvent.new(carton_id: carton.id) }
    subject { processor.send_carton_shipped_emails(event) }

    include_examples 'sends the correct email', :shipped_email do
      let(:mailer) { Spree::Config.carton_shipped_email_class }
      let(:args) { [order: carton.orders.first, carton: carton] }
    end
  end
end
