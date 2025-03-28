# frozen_string_literal: true

require "rails_helper"
RSpec.describe SolidusPromotions::PromotionCodeBatchJob, type: :job do
  let(:email) { "test@email.com" }
  let(:code_batch) do
    SolidusPromotions::PromotionCodeBatch.create!(
      promotion: create(:solidus_promotion),
      base_code: "test",
      number_of_codes: 10,
      email: email
    )
  end

  context "with a successful build" do
    before do
      allow(SolidusPromotions::PromotionCodeBatchMailer)
        .to receive(:promotion_code_batch_finished)
        .and_call_original
    end

    def codes
      SolidusPromotions::PromotionCode.pluck(:value)
    end

    context "with the default join character" do
      it "uses the default join characters", :aggregate_failures do
        subject.perform(code_batch)
        codes.each do |code|
          expect(code).to match(/^test_/)
        end
      end
    end

    context "with a custom join character" do
      let(:code_batch) do
        SolidusPromotions::PromotionCodeBatch.create!(
          promotion: create(:solidus_promotion),
          base_code: "test",
          number_of_codes: 10,
          email: email,
          join_characters: "-"
        )
      end

      it "uses the custom join characters", :aggregate_failures do
        subject.perform(code_batch)
        codes.each do |code|
          expect(code).to match(/^test-/)
        end
      end
    end

    context "with an email address" do
      it "sends an email" do
        subject.perform(code_batch)
        expect(SolidusPromotions::PromotionCodeBatchMailer)
          .to have_received(:promotion_code_batch_finished)
      end
    end

    context "with no email address" do
      let(:email) { nil }

      it "sends an email" do
        subject.perform(code_batch)
        expect(SolidusPromotions::PromotionCodeBatchMailer)
          .not_to have_received(:promotion_code_batch_finished)
      end
    end
  end

  context "with a failed build" do
    before do
      allow_any_instance_of(SolidusPromotions::PromotionCode::BatchBuilder)
        .to receive(:build_promotion_codes)
        .and_raise("Error")

      allow(SolidusPromotions::PromotionCodeBatchMailer)
        .to receive(:promotion_code_batch_errored)
        .and_call_original

      expect { subject.perform(code_batch) }
        .to raise_error RuntimeError
    end

    context "with an email address" do
      it "sends an email" do
        expect(SolidusPromotions::PromotionCodeBatchMailer)
          .to have_received(:promotion_code_batch_errored)
      end
    end

    context "with no email address" do
      let(:email) { nil }

      it "sends an email" do
        expect(SolidusPromotions::PromotionCodeBatchMailer)
          .not_to have_received(:promotion_code_batch_errored)
      end
    end
  end
end
