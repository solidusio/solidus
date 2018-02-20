# frozen_string_literal: true

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

    context "when no initial value has been set" do
      context "and an argument is sent" do
        let(:value) { "full-width" }
        it { is_expected.to eq "full-width" }
      end

      context "and no argument is sent" do
        let(:value) { nil }
        it { is_expected.to be_nil }
      end
    end

    context "when an initial value is set" do
      before { admin_layout("full-width") }

      context "and it is called again without an argument" do
        let(:value) { nil }
        it { is_expected.to eq "full-width" }
      end

      context "and it is called again with an argument" do
        let(:value) { "centered" }
        it { is_expected.to eq "centered" }
      end
    end
  end
end
