require 'spec_helper'

describe Spree::NotificationDispatch, type: :model do
  let(:message) { :order_confirm }
  let(:arguments) { create(:completed_order_with_totals) }

  after do
    # reset
    Spree::NotificationDispatch.only_messages = nil
    Spree::NotificationDispatch.except_messages = nil
  end

  it "has ActionMailerDispatch as default delivery" do
    expect(Spree::NotificationDispatch.delivery_class_name).to eq("Spree::NotificationDispatch::ActionMailerDispatch")
    expect(Spree::NotificationDispatch.new(message).delivery_class_name).to eq("Spree::NotificationDispatch::ActionMailerDispatch")
  end

  it "sends an email with good params" do
    expect {
      Spree::NotificationDispatch.new(message).deliver(*arguments)
    }.to change{ ActionMailer::Base.deliveries.count }.by(1)
  end

  describe "with mocked delivery class" do
    let(:arguments) { build(:completed_order_with_totals) }
    let(:mock_instance) { double("delivery_class") }

    around do |example|
      ::DummyDeliveryDispatch = Class.new do
        def initialize(message)
        end

        def deliver(*args)
        end
      end

      orig_delivery_class_name = Spree::NotificationDispatch.delivery_class_name
      Spree::NotificationDispatch.delivery_class_name = "DummyDeliveryDispatch"

      example.run

      Spree::NotificationDispatch.delivery_class_name = orig_delivery_class_name
      Object.send(:remove_const, :DummyDeliveryDispatch)
    end
    before do
      allow(::DummyDeliveryDispatch).to receive(:new).with(message).and_return(mock_instance)
    end

    describe "good arguments" do
      before do
        expect(::DummyDeliveryDispatch).to receive(:new).with(message).and_return(mock_instance)
      end

      it "sends to delivery class with good parameters" do
        expect(mock_instance).to receive(:deliver).with(*arguments)
        Spree::NotificationDispatch.new(message).deliver(*arguments)
      end
    end

    describe "Spree::Config[:send_core_emails] false" do
      before do
        Spree::Config.send_core_emails = false
      end
      it "does not send" do
        expect(::DummyDeliveryDispatch).not_to receive(:new)
        Spree::NotificationDispatch.new(message).deliver(*arguments)
      end
    end

    describe "only_messages" do
      it "sends if message is included in .only_messages" do
        Spree::NotificationDispatch.only_messages = [message, :whatever]
        expect(mock_instance).to receive(:deliver).with(*arguments)
        Spree::NotificationDispatch.new(message).deliver(*arguments)
      end
      it "does not send if message is not included in .only_messages" do
        Spree::NotificationDispatch.only_messages = [:something_else, :other]
        expect(::DummyDeliveryDispatch).not_to receive(:new).with(message)
        Spree::NotificationDispatch.new(message).deliver(*arguments)
      end
    end

    describe "except_messages" do
      it "sends if message is not included in .except_messages" do
        Spree::NotificationDispatch.except_messages = [:something_else, :other]
        expect(mock_instance).to receive(:deliver).with(*arguments)
        Spree::NotificationDispatch.new(message).deliver(*arguments)
      end
      it "does not send if message is not included in .except_messages" do
        Spree::NotificationDispatch.except_messages = [message, :whatever]
        expect(::DummyDeliveryDispatch).not_to receive(:new).with(message)
        Spree::NotificationDispatch.new(message).deliver(*arguments)
      end
    end

    describe "bad arguments" do
      it "#new raises on unrecognized message type" do
        expect {
          Spree::NotificationDispatch.new(:no_such_method)
        }.to raise_error(ArgumentError)
      end

      it "#deliver raises on bad parameters" do
        expect {
          Spree::NotificationDispatch.new(message).deliver(:one, :two, :three, :bad)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
