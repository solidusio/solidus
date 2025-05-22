# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Tax::TaxHelpers do
  before do
    stub_const('DummyClass', Class.new do
      include Spree::Tax::TaxHelpers

      def valid_rates(item)
        rates_for_item(item)
      end
    end)
  end

  let(:tax_category) { create(:tax_category) }
  let(:irrelevant_tax_category) { create(:tax_category) }

  let(:item) { create(:line_item, variant:) }
  let(:variant) { create(:variant, tax_category:) }
  let(:tax_address) { item.order.tax_address }
  let(:zone) { create(:zone, name: "Country Zone", countries: [tax_address.country]) }

  let!(:tax_rate) do
    create(:tax_rate, tax_categories: [tax_category], zone:)
  end

  subject { DummyClass.new.valid_rates(item) }

  describe '#rates_for_item' do
    it 'returns tax rates that match the tax category of the given item' do
      expect(subject).to contain_exactly(tax_rate)
    end

    context 'when multiple rates exist that are currently not valid' do
      let(:starts_at) { 1.day.from_now }
      let(:expires_at) { 2.days.from_now }

      let!(:invalid_tax_rate) do
        create(:tax_rate, tax_categories: [tax_category], zone:,
               starts_at:, expires_at:)
      end

      it 'returns only active rates that match the tax category of given item' do
        expect(Spree::TaxRate.for_address(tax_address)).to contain_exactly(tax_rate, invalid_tax_rate)

        expect(subject).to contain_exactly(tax_rate)
      end
    end

    context "when the line_item's variant's tax_category is changed" do
      let(:new_tax_category) { create(:tax_category) }
      before do
        variant.update(tax_category: new_tax_category)
        tax_rate.update(tax_categories: [new_tax_category])
      end

      it "returns the new tax rate for the variant's tax category" do
        expect(subject).to contain_exactly(tax_rate)
      end
    end

    context "when item is a shipping_rate" do
      let(:item) { create(:shipping_rate, shipping_method:) }
      let(:shipping_method) { create(:shipping_method, tax_category:) }

      it "returns the tax rate for the shipping_method's tax category" do
        expect(subject).to contain_exactly(tax_rate)
      end

      context "when the shipping_method's tax_category is changed" do
        let(:new_tax_category) { create(:tax_category) }
        before do
          shipping_method.update(tax_category: new_tax_category)
          tax_rate.update(tax_categories: [new_tax_category])
        end

        it "returns the new tax rate for the shipping_method's tax category" do
          expect(subject).to contain_exactly(tax_rate)
        end
      end
    end

    context "when tax_reverse_charge_mode is strict and address is enabled" do
      let(:tax_category) { create(:tax_category, tax_reverse_charge_mode: 'strict') }

      before do
        allow(tax_address).to receive(:reverse_charge_status_enabled?).and_return(true)
      end

      it "returns an empty array" do
        expect(subject).to be_empty
      end
    end

    context "when tax_reverse_charge_mode is strict and address is not enabled" do
      let(:tax_category) { create(:tax_category, tax_reverse_charge_mode: 'strict') }

      before do
        allow(tax_address).to receive(:reverse_charge_status_enabled?).and_return(false)
      end

      it "returns the applicable tax rate" do
        expect(subject).to contain_exactly(tax_rate)
      end
    end

    context "when tax_reverse_charge_mode is loose and address is disabled" do
      let(:tax_category) { create(:tax_category, tax_reverse_charge_mode: 'loose') }

      before do
        allow(tax_address).to receive(:reverse_charge_status_disabled?).and_return(true)
      end

      it "returns the applicable tax rate" do
        expect(subject).to contain_exactly(tax_rate)
      end
    end

    context "when tax_reverse_charge_mode is loose and address is not disabled" do
      let(:tax_category) { create(:tax_category, tax_reverse_charge_mode: 'loose') }

      before do
        allow(tax_address).to receive(:reverse_charge_status_disabled?).and_return(false)
      end

      it "returns an empty array" do
        expect(subject).to be_empty
      end
    end

    context "when tax_reverse_charge_mode is disabled" do
      let(:tax_category) { create(:tax_category, tax_reverse_charge_mode: 'disabled') }

      it "returns the applicable tax rate" do
        expect(subject).to contain_exactly(tax_rate)
      end
    end
  end

  describe '#tax_applicable?' do
    let(:tax_category) { create(:tax_category, tax_reverse_charge_mode: tax_reverse_charge_mode) }
    let(:address) { create(:address) }

    subject { DummyClass.new.send(:tax_applicable?, tax_category, address) }

    context 'when tax_reverse_charge_mode is strict' do
      let(:tax_reverse_charge_mode) { 'strict' }

      context 'when address is enabled' do
        before { allow(address).to receive(:reverse_charge_status_enabled?).and_return(true) }

        it { is_expected.to be_falsey }
      end

      context 'when address is not enabled' do
        before { allow(address).to receive(:reverse_charge_status_enabled?).and_return(false) }

        it { is_expected.to be_truthy }
      end
    end

    context 'when tax_reverse_charge_mode is loose' do
      let(:tax_reverse_charge_mode) { 'loose' }

      context 'when address is disabled' do
        before { allow(address).to receive(:reverse_charge_status_disabled?).and_return(true) }

        it { is_expected.to be_truthy }
      end

      context 'when address is not disabled' do
        before { allow(address).to receive(:reverse_charge_status_disabled?).and_return(false) }

        it { is_expected.to be_falsey }
      end
    end

    context 'when tax_reverse_charge_mode is disabled' do
      let(:tax_reverse_charge_mode) { 'disabled' }

      it { is_expected.to be_truthy }
    end
  end
end
