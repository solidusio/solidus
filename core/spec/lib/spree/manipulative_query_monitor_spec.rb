# frozen_string_literal: true

require 'rails_helper'
require 'spree/manipulative_query_monitor'

RSpec.describe Spree::ManipulativeQueryMonitor do
  describe ".call" do
    it "logs when a create query is detected" do
      allow(Rails.logger).to receive(:warn)

      described_class.call do
        create :user
      end

      expect(Rails.logger).to have_received(:warn).with(/Detected 1 manipulative queries.*INSERT.*/)
      expect(Rails.logger).to have_received(:warn).with(/.*manipulative_query_monitor_spec.rb.*/)
    end

    it "does not log when a select query is not detected" do
      allow(Rails.logger).to receive(:warn)

      user = create :user

      described_class.call do
        user.reload
      end

      expect(Rails.logger).to_not have_received(:warn)
    end

    it "logs when an update query is detected" do
      allow(Rails.logger).to receive(:warn)

      user = create :user

      described_class.call do
        user.update(email: "snowball@example.com")
      end

      expect(Rails.logger).to have_received(:warn).with(/Detected 1 manipulative queries.*UPDATE.*/)
      expect(Rails.logger).to have_received(:warn).with(/.*manipulative_query_monitor_spec.rb.*/)
    end

    it "logs when a delete query is detected" do
      allow(Rails.logger).to receive(:warn)

      user = create :user

      described_class.call do
        user.delete
      end

      expect(Rails.logger).to have_received(:warn).with(/Detected 1 manipulative queries.*DELETE FROM.*/)
      expect(Rails.logger).to have_received(:warn).with(/.*manipulative_query_monitor_spec.rb.*/)
    end
  end
end
