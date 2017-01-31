require "spec_helper"

describe Spree::PromotionCodeBatch, type: :model do
  include ActiveJob::TestHelper

  subject do
    described_class.create!(
      promotion_id: create(:promotion).id,
      base_code: "abc",
      number_of_codes: 1,
      error: nil,
      email: "test@email.com"
    )
  end

  describe "#process" do
    context "with a pending code batch" do
      it "should call the worker" do
        ActiveJob::Base.queue_adapter = :test

        expect { subject.process }
          .to have_enqueued_job(Spree::PromotionCodeBatchJob)

        clear_enqueued_jobs
      end

      it "should update the state to processing" do
        subject.process

        expect(subject.state).to eq("processing")
      end
    end

    context "with a processing batch" do
      before { subject.update_attribute(:state, "processing") }

      it "should raise an error" do
        expect{ subject.process }.to raise_error Spree::PromotionCodeBatch::CantProcessStartedBatch
      end
    end

    context "with a completed batch" do
      before { subject.update_attribute(:state, "completed") }

      it "should raise an error" do
        expect{ subject.process }.to raise_error Spree::PromotionCodeBatch::CantProcessStartedBatch
      end
    end

    context "with a failed batch" do
      before { subject.update_attribute(:state, "failed") }

      it "should raise an error" do
        expect{ subject.process }.to raise_error Spree::PromotionCodeBatch::CantProcessStartedBatch
      end
    end
  end
end
