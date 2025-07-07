# frozen_string_literal: true

module Spree
  # Base class for all Solidus background jobs
  class BaseJob < ActiveJob::Base # rubocop:disable Rails/ApplicationJob
    # Automatically retry jobs that encountered a deadlock
    retry_on ActiveRecord::Deadlocked

    # Most jobs are safe to ignore if the underlying records are no longer available
    discard_on ActiveJob::DeserializationError
  end
end
