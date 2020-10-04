# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PromotionCode::BatchBuilder do
  let(:promotion) { create(:promotion) }
  let(:base_code) { "abc" }
  let(:options) { {} }
  let(:number_of_codes) { 10 }
  let(:promotion_code_batch) do
    Spree::PromotionCodeBatch.create!(
      promotion_id: promotion.id,
      base_code: base_code,
      number_of_codes: number_of_codes,
      email: "test@email.com"
    )
  end

  subject { described_class.new(promotion_code_batch, options) }

  describe "#build_promotion_codes" do
    context "with a failed build" do
      before do
        allow(subject).to receive(:generate_random_codes).and_raise "Error"

        expect { subject.build_promotion_codes }.to raise_error RuntimeError
      end

      it "updates the error and state on promotion batch" do
        expect(promotion_code_batch.reload.error).to eq("#<RuntimeError: Error>")
        expect(promotion_code_batch.reload.state).to eq("failed")
      end
    end

    context "with a successful build" do
      before do
        allow(Spree::PromotionCodeBatchMailer)
          .to receive(:promotion_code_batch_finished)
          .and_call_original

        subject.build_promotion_codes
      end

      it "update the promotion codes count for the batch" do
        expect(promotion_code_batch.promotion_codes.count).to eq(10)
      end

      it "builds the correct number of codes" do
        expect(subject.promotion.codes.size).to eq(10)
      end

      it "builds codes with distinct values" do
        expect(subject.promotion.codes.map(&:value).uniq.size).to eq(10)
      end

      it "updates the promotion code batch state to completed" do
        expect(promotion_code_batch.state).to eq("completed")
      end
    end

    context "with likely code contention" do
      let(:number_of_codes) { 50 }
      let(:options) do
        {
          batch_size: 10,
          sample_characters: (0..9).to_a.map(&:to_s),
          random_code_length: 2
        }
      end

      it "creates the correct number of codes" do
        subject.build_promotion_codes
        expect(promotion.codes.size).to eq(number_of_codes)
      end
    end
  end

  describe "#join_character" do
    context "with the default join charachter _" do
      it "builds codes with the same base prefix" do
        subject.build_promotion_codes

        values = subject.promotion.codes.map(&:value)
        expect(values.all? { |val| val.starts_with?("#{base_code}_") }).to be true
      end
    end

    context "with a custom join separator" do
      let(:promotion_code_batch) do
        Spree::PromotionCodeBatch.create!(
          promotion_id: promotion.id,
          base_code: base_code,
          number_of_codes: number_of_codes,
          email: "test@email.com",
          join_characters: "x"
        )
      end

      it "builds codes with the same base prefix" do
        subject.build_promotion_codes

        values = subject.promotion.codes.map(&:value)
        expect(values.all? { |val| val.starts_with?("#{base_code}x") }).to be true
      end
    end
  end
end
