# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::CodeBatchMailer, type: :mailer do
  let(:promotion) { create(:friendly_promotion, name: "Promotion Test") }
  let(:code_batch) do
    SolidusFriendlyPromotions::CodeBatch.create!(
      promotion_id: promotion.id,
      base_code: "test",
      number_of_codes: 10,
      email: "test@email.com"
    )
  end

  describe "#code_batch_finished" do
    subject { described_class.code_batch_finished(code_batch) }

    it "sends the email to the email attached to the promotion code batch " do
      expect(subject.to).to eq([code_batch.email])
    end

    it "contains the number of codes created" do
      expect(subject.body).to include("All 10 codes have been created")
    end

    it "contains the name of the promotion" do
      expect(subject.body).to include(promotion.name)
    end
  end

  describe "#code_batch_errored" do
    before { code_batch.update(error: "Test error") }
    subject { described_class.code_batch_errored(code_batch) }

    it "sends the email to the email attached to the promotion code batch " do
      expect(subject.to).to eq([code_batch.email])
    end

    it "contains the error" do
      expect(subject.body).to include("Test error")
    end

    it "contains the name of the promotion" do
      expect(subject.body).to include(promotion.name)
    end
  end
end
