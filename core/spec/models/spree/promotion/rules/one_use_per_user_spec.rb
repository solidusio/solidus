# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Rules::OneUsePerUser, type: :model do
  let(:rule) { described_class.new }

  describe '#eligible?(order)' do
    subject { rule.eligible?(order) }
    let(:order) { double Spree::Order, user: user }
    let(:user) { double Spree::LegacyUser }
    let(:promotion) { stub_model Spree::Promotion, used_by?: used_by }
    let(:used_by) { false }

    before { rule.promotion = promotion }

    context 'when the order is assigned to a user' do
      context 'when the user has used this promotion before' do
        let(:used_by) { true }

        it { is_expected.to be false }
        it "sets an error message" do
          subject
          expect(rule.eligibility_errors.full_messages.first).
            to eq "This coupon code can only be used once per user."
        end
        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code]).
            to eq :limit_once_per_user
        end
      end

      context 'when the user has not used this promotion before' do
        it { is_expected.to be true }
      end
    end

    context 'when the order is not assigned to a user' do
      let(:user) { nil }
      it { is_expected.to be false }
      it "sets an error message" do
        subject
        expect(rule.eligibility_errors.full_messages.first).
          to eq "You need to login before applying this coupon code."
      end
      it "sets an error code" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.details[:base].first[:error_code]).
          to eq :no_user_specified
      end
    end
  end
end
