# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Money do
  before do
    stub_spree_preferences(currency: "USD")
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
        let(:amount){ BigDecimal('10.00') }
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
      money = Spree::Money.new(10, with_currency: true, html_wrap: false)
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
        money = Spree::Money.new(10, currency: 'CAD', with_currency: true, html_wrap: false)
        expect(money.to_s).to eq("$10.00 CAD")
      end
    end

    context "when currency is specified in Japanese Yen" do
      it "uses the currency param over the global configuration" do
        money = Spree::Money.new(100, currency: 'JPY', html_wrap: false)
        expect(money.to_s).to eq("¥100")
      end
    end
  end

  context "symbol positioning" do
    it "passed in option" do
      money = Spree::Money.new(10, format: '%n %u', html_wrap: false)
      expect(money.to_s).to eq("10.00 $")
    end

    it "config option" do
      money = Spree::Money.new(10, format: '%n %u', html_wrap: false)
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
      stub_spree_preferences(currency: "JPY")
    end

    it "formats correctly" do
      money = Spree::Money.new(1000, html_wrap: false)
      expect(money.to_s).to eq("¥1,000")
    end
  end

  context "EUR" do
    before do
      stub_spree_preferences(currency: "EUR")
    end

    # Regression test for https://github.com/spree/spree/issues/2634
    it "formats as plain by default" do
      money = Spree::Money.new(10, format: '%n %u')
      expect(money.to_s).to eq("10.00 €")
    end

    it "formats as HTML if asked (nicely) to" do
      money = Spree::Money.new(10, format: '%n %u')
      # The HTML'ified version of "10.00 €"
      expect(money.to_html).to eq("<span class=\"money-whole\">10</span><span class=\"money-decimal-mark\">.</span><span class=\"money-decimal\">00</span> <span class=\"money-currency-symbol\">&#x20AC;</span>")
    end

    it "formats as HTML with currency" do
      money = Spree::Money.new(10, format: '%n %u', with_currency: true)
      # The HTML'ified version of "10.00 €"
      expect(money.to_html).to eq("<span class=\"money-whole\">10</span><span class=\"money-decimal-mark\">.</span><span class=\"money-decimal\">00</span> <span class=\"money-currency-symbol\">&#x20AC;</span> <span class=\"money-currency\">EUR</span>")
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

  it "includes Comparable" do
    expect(described_class).to include(Comparable)
  end

  describe "<=>" do
    let(:usd_10) { Spree::Money.new(10, currency: "USD") }
    let(:usd_20) { Spree::Money.new(20, currency: "USD") }
    let(:usd_30) { Spree::Money.new(30, currency: "USD") }

    it "compares the two amounts" do
      expect(usd_20 <=> usd_20).to eq 0
      expect(usd_20 <=> usd_10).to be > 0
      expect(usd_20 <=> usd_30).to be < 0
    end

    context "with a non Spree::Money object" do
      it "raises an error" do
        expect { usd_10 <=> 20 }.to raise_error(TypeError)
      end
    end

    context "with differing currencies" do
      let(:cad) { Spree::Money.new(10, currency: "CAD") }

      it "raises an error" do
        expect { usd_10 <=> cad }.to raise_error(
          Spree::Money::DifferentCurrencyError
        )
      end
    end
  end
end
