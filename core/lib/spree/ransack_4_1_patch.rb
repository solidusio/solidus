# frozen_string_literal: true

require "ransack/version"

return unless Ransack::VERSION.start_with?("4.1.")

module RansackNodeConditionPatch
  private

  # Waiting for https://github.com/activerecord-hackery/ransack/pull/1468
  def casted_array?(predicate)
    predicate.is_a?(Arel::Nodes::Casted) && predicate.value.is_a?(Array)
  end

  Ransack::Nodes::Condition.prepend(self)
end
