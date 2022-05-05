# frozen_string_literal: true

module Spree
  class LogEntry < Spree::Base
    belongs_to :source, polymorphic: true, optional: true

    def parsed_details
      @details ||= YAML.safe_load(details, permitted_classes: [ActiveMerchant::Billing::Response])
    end
  end
end
