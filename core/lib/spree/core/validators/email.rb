# frozen_string_literal: true

module Spree
  # == An ActiveModel Email Validator
  #
  # === Usage
  #
  #     require 'spree/core/validators/email'
  #
  #     class Person < ApplicationRecord
  #       validates :email_address, 'spree/email' => true
  #     end
  #
  class EmailValidator < ActiveModel::EachValidator
    EMAIL_REGEXP = URI::MailTo::EMAIL_REGEXP
    EMAIL_DOMAIN_REGEXP = /\.[a-z]+/i

    def validate_each(record, attribute, value)
      unless valid_email?(value)
        record.errors.add(attribute, :invalid, { value: value }.merge!(options))
      end
    end

    def valid_email?(value)
      EMAIL_REGEXP.match?(value) && EMAIL_DOMAIN_REGEXP.match?(value)
    end
  end
end
