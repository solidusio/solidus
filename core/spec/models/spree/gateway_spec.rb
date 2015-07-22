require 'spec_helper'

describe Spree::Gateway, :type => :model do
  class Provider
    def initialize(options)
    end

    def imaginary_method
      'imaginary!'
    end
  end

  class TestGateway < Spree::Gateway
    def provider_class
      Provider
    end
  end

  it "passes through all arguments on a method_missing call" do
    expect(TestGateway.new.imaginary_method).to eq 'imaginary!'
  end

  context "fetching payment sources" do
    let(:user) { create :user }
    let(:order) { Spree::Order.create(user: user, completed_at: completed_at) }

    let(:payment_method) { create(:credit_card_payment_method) }

    let(:cc) do
      create(:credit_card,
             payment_method: payment_method,
             gateway_customer_profile_id: "EFWE",
             user: cc_user)
    end

    let(:payment) do
      create(:payment, order: order, source: cc, payment_method: payment_method)
    end

    context 'order is not complete and credit card user is nil' do
      let(:cc_user) { nil }
      let(:completed_at) { nil }

      it "finds no credit cards associated to the order" do
        expect(payment_method.reusable_sources(payment.order)).to be_empty
      end
    end

    context 'order is complete but credit card user is nil' do
      let(:cc_user) { nil }
      let(:completed_at) { Date.yesterday }

      it "finds credit cards associated on a order completed" do
        expect(payment_method.reusable_sources(payment.order)).to eq [cc]
      end
    end

    context 'order is not complete but credit card has user' do
      let(:cc_user) { user }
      let(:completed_at) { nil }

      it "finds credit cards associated to the user" do
        expect(payment_method.reusable_sources(payment.order)).to eq [cc]
      end
    end
  end

  context 'using preference_source' do
    let(:klass){ Spree::Gateway::Bogus }
    before do
      Spree::Config.static_model_preferences.add(klass, 'test_preference_source', server: 'bar')
    end
    after do
      Spree::Config.static_model_preferences.for_class(klass).clear
    end
    let(:payment_method){ create(:credit_card_payment_method, preference_source: 'test_preference_source') }

    it "reads static preferences" do
      expect(payment_method.options).to eq({:server=>"bar"})
    end
  end
end
