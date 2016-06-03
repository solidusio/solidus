require 'spec_helper'

describe Spree::NotificationDispatch::ActionMailerDispatch, type: :model do
  let(:message) { :order_confirm }
  let(:arguments) { create(:completed_order_with_totals) }
  let(:expected_mailer_class_name) { Spree::NotificationDispatch::ActionMailerDispatch.mailer_dispatch_table[message].first }
  let(:expected_mailer_method_name) { Spree::NotificationDispatch::ActionMailerDispatch.mailer_dispatch_table[message].second }

  it "sends email using configured mailer" do
    # somehow deliver_later means it's called twice? I dunno.
    expect(expected_mailer_class_name.constantize).to receive(expected_mailer_method_name).at_least(:once).with(*arguments).and_call_original
    expect {
      Spree::NotificationDispatch::ActionMailerDispatch.new(message).deliver(arguments)
    }.to change{ ActionMailer::Base.deliveries.count }.by(1)
  end

  describe "action_mail_object" do
    it "returns ActionMailer::MessageDelivery" do
      expect(expected_mailer_class_name.constantize).to receive(expected_mailer_method_name).at_least(:once).with(*arguments).and_call_original

      result = Spree::NotificationDispatch::ActionMailerDispatch.new(message).action_mail_object(*arguments)

      expect(result).to be_kind_of(ActionMailer::MessageDelivery)
      expect(result).to respond_to(:deliver_later)
    end
  end

  describe "with unrecognized message type" do
    it "raises on #new" do
      expect {
        Spree::NotificationDispatch::ActionMailerDispatch.new(:no_such_message_type)
      }.to raise_error(ArgumentError)
    end
  end

  describe "custom configured mailer and method" do
    let(:mock_mail) { double("mail", deliver_later: true ) }
    let(:custom_method) { :some_method }

    around do |example|
      ::DummyMailer = Class.new
      orig_dispatch = Spree::NotificationDispatch::ActionMailerDispatch.mailer_dispatch_table[message]
      Spree::NotificationDispatch::ActionMailerDispatch.mailer_dispatch_table[message] =
        ["DummyMailer", custom_method]

      example.run

      Spree::NotificationDispatch::ActionMailerDispatch.mailer_dispatch_table[message] = orig_dispatch
      Object.send(:remove_const, :DummyMailer)
    end

    it "sends as configured" do
      expect(::DummyMailer).to receive(custom_method).with(*arguments).and_return(mock_mail)
      Spree::NotificationDispatch::ActionMailerDispatch.new(message).deliver(*arguments)
    end
  end

  describe "legacy Spree::Config.carton_shipped_email_class" do
    let(:mock_mail) { double("mail", deliver_later: true ) }
    let(:message) { :carton_shipped }
    around do |example|
      ::DummyMailer = Class.new
      example.run
      Object.send(:remove_const, :DummyMailer)
    end
    before do
      Spree::Config.carton_shipped_email_class = DummyMailer
    end

    it "uses, with deprecation message" do
      expect(::DummyMailer).to receive(expected_mailer_method_name).with(*arguments).and_return(mock_mail)
      expect(Spree::Deprecation).to receive(:warn)
      Spree::NotificationDispatch::ActionMailerDispatch.new(message).deliver(*arguments)
    end
  end
end
