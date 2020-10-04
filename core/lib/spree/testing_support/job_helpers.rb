# frozen_string_literal: true

module Spree
  module TestingSupport
    module JobHelpers
      def perform_enqueued_jobs
        adapter = ActiveJob::Base.queue_adapter

        old = adapter.perform_enqueued_jobs
        old_at = adapter.perform_enqueued_at_jobs

        begin
          adapter.perform_enqueued_jobs = true
          adapter.perform_enqueued_at_jobs = true

          yield
        ensure
          adapter.perform_enqueued_jobs = old
          adapter.perform_enqueued_at_jobs = old_at
        end
      end
    end
  end
end
