# frozen_string_literal: true

module Spree
  class LogEntry < Spree::Base
    belongs_to :source, polymorphic: true

    def parsed_details
      @details ||= YAML.load(details)
    end
  end
end
