require 'spec_helper'

describe Spree::Admin::BaseHelper, type: :helper do
  include Spree::Admin::BaseHelper

  context "#datepicker_field_value" do
    it "should return nil when date is empty" do
      date = nil
      expect(datepicker_field_value(date)).to be_nil
    end

    it "should return a formatted date when date is present" do
      date = "2013-08-14".to_time
      expect(datepicker_field_value(date)).to eq("2013/08/14")
    end
  end

  describe "#admin_layout" do
    subject { admin_layout(value) }

    context "when an initial value is set" do
      let(:value) { "full-width" }

      it "sets and returns the value passed to it" do
        expect(subject).to eq value
      end

      context "and you call it again without an argument" do
        before { admin_layout(value) }
        let(:value) { nil }

        it "returns the initial value that was set" do
          expect(subject).to eq value
        end
      end
    end

    context "when no initial value has been set and you send no arguments" do
      let(:value) { nil }
      it { is_expected.to be_nil }
    end
  end
end
