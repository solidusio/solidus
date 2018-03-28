# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Spree::PromotionCodeBatchJob, type: :job do
  let(:email) { "test@email.com" }
  let(:promotion_code_batch) do
    Spree::PromotionCodeBatch.create!(
      promotion_id: create(:promotion).id,
      base_code: "test",
      number_of_codes: 10,
      email: email
    )
  end
  context "with a successful build" do
    before do
      allow(Spree::PromotionCodeBatchMailer)
        .to receive(:promotion_code_batch_finished)
        .and_call_original
    end

    def codes
      Spree::PromotionCode.pluck(:value)
    end

    context 'with the default join character' do
      it 'uses the default join characters', :aggregate_failures do
        subject.perform(promotion_code_batch)
        codes.each do |code|
          expect(code).to match(/^test_/)
        end
      end
    end
    context 'with a custom join character' do
      let(:promotion_code_batch) do
        Spree::PromotionCodeBatch.create!(
          promotion_id: create(:promotion).id,
          base_code: "test",
          number_of_codes: 10,
          email: email,
          join_characters: '-'
        )
      end
      it 'uses the custom join characters', :aggregate_failures do
        subject.perform(promotion_code_batch)
        codes.each do |code|
          expect(code).to match(/^test-/)
        end
      end
    end
    context "with an email address" do
      it "sends an email" do
        subject.perform(promotion_code_batch)
        expect(Spree::PromotionCodeBatchMailer)
          .to have_received(:promotion_code_batch_finished)
      end
    end
    context "with no email address" do
      let(:email) { nil }
      it "sends an email" do
        subject.perform(promotion_code_batch)
        expect(Spree::PromotionCodeBatchMailer)
          .to_not have_received(:promotion_code_batch_finished)
      end
    end
  end

  context "with a failed build" do
    before do
      allow_any_instance_of(Spree::PromotionCode::BatchBuilder)
        .to receive(:build_promotion_codes)
        .and_raise("Error")

      allow(Spree::PromotionCodeBatchMailer)
        .to receive(:promotion_code_batch_errored)
        .and_call_original

      expect { subject.perform(promotion_code_batch) }
        .to raise_error RuntimeError
    end

    context "with an email address" do
      it "sends an email" do
        expect(Spree::PromotionCodeBatchMailer)
          .to have_received(:promotion_code_batch_errored)
      end
    end

    context "with no email address" do
      let(:email) { nil }
      it "sends an email" do
        expect(Spree::PromotionCodeBatchMailer)
          .to_not have_received(:promotion_code_batch_errored)
      end
    end
  end
end
