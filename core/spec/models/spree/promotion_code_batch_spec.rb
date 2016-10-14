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
    it "should call the worker" do
      ActiveJob::Base.queue_adapter = :test

      expect { subject.process }
        .to have_enqueued_job(Spree::PromotionCodeBatchJob)

      clear_enqueued_jobs
    end

    context "with a finished batch" do
      before do
        Spree::PromotionCode::BatchBuilder.new(subject).build_promotion_codes
      end

      it "should raise an error" do
        expect{ subject.process }.to raise_error RuntimeError
      end
    end
  end
end
