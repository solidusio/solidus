# frozen_string_literal: true

module PartialDoubleVerificationExampleGroup
  extend ActiveSupport::Concern

  included do
    around do |example|
      without_partial_double_verification { example.run }
    end
  end
end

RSpec.configure do |config|
  config.include PartialDoubleVerificationExampleGroup,
                 partial_double_verification: false
end
