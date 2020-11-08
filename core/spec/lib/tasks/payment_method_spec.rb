# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'payment_method:deactivate_unsupported_payment_methods' do
  include_context(
    'rake',
    task_name: 'payment_method:deactivate_unsupported_payment_methods',
    task_path: Spree::Core::Engine.root.join('lib/tasks/payment_method.rake'),
  )

  let!(:unsupported_payment_method_id) { 0 }
  let!(:unsupported_payment_method) { create(:payment_method, id: unsupported_payment_method_id) }
  let!(:supported_payment_method) { create(:payment_method, id: 1) }

  def unsupported_payment_method_reloaded
    Spree::PaymentMethod.find_by(id: unsupported_payment_method_id)
  end

  before do
    unsupported_payment_method.update type: 'UnsupportedPaymentMethod'
  end

  context "with an unsupported payment method" do
    it "allows payment method records retrieval" do
      task.invoke

      expect {
        Spree::PaymentMethod.find_by(id: unsupported_payment_method_id)
      }.not_to raise_error
    end
  end

  context "on an unsupported payment method" do
    before { task.invoke }
    subject { unsupported_payment_method_reloaded }

    it "sets payment method type to 'Spree::PaymentMethod'" do
      expect(subject.type).to eq 'Spree::PaymentMethod'
    end

    it "sets payment method type_before_removal correctly" do
      expect(subject.type_before_removal).to eq 'UnsupportedPaymentMethod'
    end

    it "resets payment method active flag" do
      expect(subject.active).to be false
    end

    it "resets payment method available_to_users flag" do
      expect(subject.available_to_users).to be false
    end

    it "resets payment method available_to_admin flag" do
      expect(subject.available_to_admin).to be false
    end
  end

  context "on a supported payment method" do
    it "does not change payment method attributes" do
      expect { task.invoke }.not_to change { supported_payment_method.reload }
    end
  end
end
