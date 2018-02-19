# frozen_string_literal: true

RSpec::Matchers.define :be_paginated do
  match do |actual|
    %w[count total_count current_page pages per_page].all? do |attr|
      actual[attr].is_a?(Integer)
    end
  end
end
