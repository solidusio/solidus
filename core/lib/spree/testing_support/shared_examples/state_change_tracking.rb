# frozen_string_literal: true

RSpec.shared_examples "tracking state changes" do
  context "with track_state_change? true" do
    before do
      expect(stateful).to receive(:track_state_change?).and_return(true)
    end

    it "enqueues state change tracking job" do
      expect { stateful.update!(state:) }
        .to enqueue_job(Spree::StateChangeTrackingJob)
    end
  end

  context "with track_state_change? false" do
    before do
      expect(stateful).to receive(:track_state_change?).and_return(false)
    end

    it "does not enqueue state change tracking job" do
      expect { stateful.update!(state:) }
        .not_to enqueue_job(Spree::StateChangeTrackingJob)
    end
  end
end
