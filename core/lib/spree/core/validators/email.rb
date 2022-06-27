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
    # Use Spree::Config.default_email_regexp instead
    deprecate_constant :EMAIL_REGEXP

    def validate_each(record, attribute, value)
      unless Spree::Config.default_email_regexp.match? value
        record.errors.add(attribute, :invalid, **{ value: value }.merge!(options))
      end
    end
  end
end
