# coding: utf-8
require 'spec_helper'

describe Spree::Money do
  before do
    configure_spree_preferences do |config|
      config.currency = "USD"
    end
  end

  describe '#initialize' do
    subject do
      Spree::Deprecation.silence do
        described_class.new(amount, currency: currency, with_currency: true).to_s
      end
    end

    context 'with no currency' do
      let(:currency) { nil }
      let(:amount){ 10 }
      it { should == "$10.00 USD" }
    end

    context 'with currency' do
      let(:currency){ 'USD' }

      context "CAD" do
        let(:amount){ '10.00' }
        let(:currency){ 'CAD' }
        it { should == "$10.00 CAD" }
      end

      context "with string amount" do
        let(:amount){ '10.00' }
        it { should == "$10.00 USD" }
      end

      context "with no decimal point" do
        let(:amount){ '10' }
        it { should == "$10.00 USD" }
      end

      context "with symbol" do
        let(:amount){ '$10.00' }
        it { should == "$10.00 USD" }
      end

      context "with extra currency" do
        let(:amount){ '$10.00 USD' }
        it { should == "$10.00 USD" }
      end

      context "with different currency" do
        let(:currency){ 'USD' }
        let(:amount){ '$10.00 CAD' }
        it { should == "$10.00 CAD" }
      end

      context "with commas" do
        let(:amount){ '1,000.00' }
        it { should == "$1,000.00 USD" }
      end

      context "with comma for decimal point" do
        let(:amount){ '10,00' }
        it { should == "$10.00 USD" }
      end

      context 'with fixnum' do
        let(:amount){ 10 }
        it { should == "$10.00 USD" }
      end

      context 'with float' do
        let(:amount){ 10.00 }
        it { should == "$10.00 USD" }
      end

      context 'with BigDecimal' do
        let(:amount){ BigDecimal.new('10.00') }
        it { should == "$10.00 USD" }
      end
    end
  end

  it "formats correctly" do
    money = Spree::Money.new(10)
    expect(money.to_s).to eq("$10.00")
  end

  it "can get cents" do
    money = Spree::Money.new(10)
    expect(money.cents).to eq(1000)
  end

  context "with currency" do
    it "passed in option" do
      money = Spree::Money.new(10, with_currency: true, html: false)
      expect(money.to_s).to eq("$10.00 USD")
    end
  end

  context "hide cents" do
    it "hides cents suffix" do
      money = Spree::Money.new(10, no_cents: true)
      expect(money.to_s).to eq("$10")
    end

    it "shows cents suffix" do
      money = Spree::Money.new(10)
      expect(money.to_s).to eq("$10.00")
    end
  end

  context "currency parameter" do
    context "when currency is specified in Canadian Dollars" do
      it "uses the currency param over the global configuration" do
        money = Spree::Money.new(10, currency: 'CAD', with_currency: true, html: false)
        expect(money.to_s).to eq("$10.00 CAD")
      end
    end

    context "when currency is specified in Japanese Yen" do
      it "uses the currency param over the global configuration" do
        money = Spree::Money.new(100, currency: 'JPY', html: false)
        expect(money.to_s).to eq("¥100")
      end
    end
  end

  context "symbol positioning" do
    it "passed in option" do
      money = Spree::Money.new(10, symbol_position: :after, html: false)
      expect(money.to_s).to eq("10.00 $")
    end

    it "config option" do
      money = Spree::Money.new(10, symbol_position: :after, html: false)
      expect(money.to_s).to eq("10.00 $")
    end
  end

  context "sign before symbol" do
    it "defaults to -$10.00" do
      money = Spree::Money.new(-10)
      expect(money.to_s).to eq("-$10.00")
    end

    it "passed in option" do
      money = Spree::Money.new(-10, sign_before_symbol: false)
      expect(money.to_s).to eq("$-10.00")
    end
  end

  context "JPY" do
    before do
      configure_spree_preferences do |config|
        config.currency = "JPY"
      end
    end

    it "formats correctly" do
      money = Spree::Money.new(1000, html: false)
      expect(money.to_s).to eq("¥1,000")
    end
  end

  context "EUR" do
    before do
      configure_spree_preferences do |config|
        config.currency = "EUR"
      end
    end

    # Regression test for https://github.com/spree/spree/issues/2634
    it "formats as plain by default" do
      money = Spree::Money.new(10, symbol_position: :after)
      expect(money.to_s).to eq("10.00 €")
    end

    it "formats as HTML if asked (nicely) to" do
      money = Spree::Money.new(10, symbol_position: :after)
      # The HTML'ified version of "10.00 €"
      expect(money.to_html).to eq("10.00&nbsp;&#x20AC;")
    end

    it "formats as HTML with currency" do
      money = Spree::Money.new(10, symbol_position: :after, with_currency: true)
      # The HTML'ified version of "10.00 €"
      expect(money.to_html).to eq("10.00&nbsp;&#x20AC; <span class=\"currency\">EUR</span>")
    end
  end

  describe "#as_json" do
    let(:options) { double('options') }

    it "returns the expected string" do
      money = Spree::Money.new(10)
      expect(money.as_json(options)).to eq("$10.00")
    end
  end

  describe 'subtraction' do
    context "for money objects with same currency" do
      let(:money_1) { Spree::Money.new(32.00, currency: "USD") }
      let(:money_2) { Spree::Money.new(15.00, currency: "USD") }

      it "subtracts correctly" do
        expect(money_1 - money_2).to eq(Spree::Money.new(17.00, currency: "USD"))
      end
    end

    context "when trying to subtract money objects in different currencies" do
      let(:money_1) { Spree::Money.new(32.00, currency: "EUR") }
      let(:money_2) { Spree::Money.new(15.00, currency: "USD") }

      it "will not work" do
        expect { money_1 - money_2 }.to raise_error(Money::Bank::UnknownRate)
      end
    end

    context "if other does not respond to .money" do
      let(:money_1) { Spree::Money.new(32.00, currency: "EUR") }
      let(:money_2) { ::Money.new(1500) }

      it 'raises a TypeError' do
        expect { money_1 - money_2 }.to raise_error(TypeError)
      end
    end
  end

  describe 'addition' do
    context "for money objects with same currency" do
      let(:money_1) { Spree::Money.new(37.00, currency: "USD") }
      let(:money_2) { Spree::Money.new(15.00, currency: "USD") }

      it "subtracts correctly" do
        expect(money_1 + money_2).to eq(Spree::Money.new(52.00, currency: "USD"))
      end
    end

    context "when trying to subtract money objects in different currencies" do
      let(:money_1) { Spree::Money.new(32.00, currency: "EUR") }
      let(:money_2) { Spree::Money.new(15.00, currency: "USD") }

      it "will not work" do
        expect { money_1 + money_2 }.to raise_error(Money::Bank::UnknownRate)
      end
    end

    context "if other does not respond to .money" do
      let(:money_1) { Spree::Money.new(32.00, currency: "EUR") }
      let(:money_2) { ::Money.new(1500) }

      it 'raises a TypeError' do
        expect { money_1 + money_2 }.to raise_error(TypeError)
      end
    end
  end

  describe 'equality checks' do
    context "if other does not respond to .money" do
      let(:money_1) { Spree::Money.new(32.00, currency: "EUR") }
      let(:money_2) { ::Money.new(1500) }

      it 'raises a TypeError' do
        expect { money_1 == money_2 }.to raise_error(TypeError)
      end
    end
  end
end
