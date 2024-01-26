# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Spree::PromotionCodeBatchMailer, type: :mailer do
  let(:promotion) { create(:promotion, name: "Promotion Test") }
  let(:promotion_code_batch) do
    Spree::PromotionCodeBatch.create!(
      promotion_id: promotion.id,
      base_code: "test",
      number_of_codes: 10,
      email: "test@email.com"
    )
  end

  describe "#promotion_code_batch_finished" do
    subject { described_class.promotion_code_batch_finished(promotion_code_batch) }

    it "sends the email to the email attached to the promotion code batch " do
      expect(subject.to).to eq([promotion_code_batch.email])
    end

    it "contains the number of codes created" do
      expect(subject.body).to include("All 10 codes have been created")
    end

    it "contains the name of the promotion" do
      expect(subject.body).to include(promotion.name)
    end
  end

  describe "#promotion_code_batch_errored" do
    before { promotion_code_batch.update(error: "Test error") }
    subject { described_class.promotion_code_batch_errored(promotion_code_batch) }

    it "sends the email to the email attached to the promotion code batch " do
      expect(subject.to).to eq([promotion_code_batch.email])
    end

    it "contains the error" do
      expect(subject.body).to include("Test error")
    end

    it "contains the name of the promotion" do
      expect(subject.body).to include(promotion.name)
    end
  end
end
