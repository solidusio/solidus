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
    EMAIL_REGEXP = /\A([^@\.]|[^@\.]([^@\s]*)[^@\.])@([^@\s]+\.)+[^@\s]+\z/

    def validate_each(record, attribute, value)
      unless EMAIL_REGEXP.match? value
        record.errors.add(attribute, :invalid, { value: value }.merge!(options))
      end
    end
  end
end
