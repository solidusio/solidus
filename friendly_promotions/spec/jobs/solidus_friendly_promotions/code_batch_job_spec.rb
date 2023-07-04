# frozen_string_literal: true

require 'spec_helper'
RSpec.describe SolidusFriendlyPromotions::CodeBatchJob, type: :job do
  let(:email) { "test@email.com" }
  let(:code_batch) do
    SolidusFriendlyPromotions::CodeBatch.create!(
      promotion: create(:friendly_promotion),
      base_code: "test",
      number_of_codes: 10,
      email: email
    )
  end
  context "with a successful build" do
    before do
      allow(SolidusFriendlyPromotions::CodeBatchMailer)
        .to receive(:code_batch_finished)
        .and_call_original
    end

    def codes
      SolidusFriendlyPromotions::Code.pluck(:value)
    end

    context 'with the default join character' do
      it 'uses the default join characters', :aggregate_failures do
        subject.perform(code_batch)
        codes.each do |code|
          expect(code).to match(/^test_/)
        end
      end
    end
    context 'with a custom join character' do
      let(:code_batch) do
        SolidusFriendlyPromotions::CodeBatch.create!(
          promotion: create(:friendly_promotion),
          base_code: "test",
          number_of_codes: 10,
          email: email,
          join_characters: '-'
        )
      end
      it 'uses the custom join characters', :aggregate_failures do
        subject.perform(code_batch)
        codes.each do |code|
          expect(code).to match(/^test-/)
        end
      end
    end
    context "with an email address" do
      it "sends an email" do
        subject.perform(code_batch)
        expect(SolidusFriendlyPromotions::CodeBatchMailer)
          .to have_received(:code_batch_finished)
      end
    end
    context "with no email address" do
      let(:email) { nil }
      it "sends an email" do
        subject.perform(code_batch)
        expect(SolidusFriendlyPromotions::CodeBatchMailer)
          .to_not have_received(:code_batch_finished)
      end
    end
  end

  context "with a failed build" do
    before do
      allow_any_instance_of(SolidusFriendlyPromotions::Code::BatchBuilder)
        .to receive(:build_promotion_codes)
        .and_raise("Error")

      allow(SolidusFriendlyPromotions::CodeBatchMailer)
        .to receive(:code_batch_errored)
        .and_call_original

      expect { subject.perform(code_batch) }
        .to raise_error RuntimeError
    end

    context "with an email address" do
      it "sends an email" do
        expect(SolidusFriendlyPromotions::CodeBatchMailer)
          .to have_received(:code_batch_errored)
      end
    end

    context "with no email address" do
      let(:email) { nil }
      it "sends an email" do
        expect(SolidusFriendlyPromotions::CodeBatchMailer)
          .to_not have_received(:code_batch_errored)
      end
    end
  end
end
