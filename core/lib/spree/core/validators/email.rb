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
    include ActiveSupport::Deprecation::DeprecatedConstantAccessor

    SPREE_EMAIL_REGEXP = Spree::Config.default_email_regexp
    deprecate_constant 'EMAIL_REGEXP', "#{name}::SPREE_EMAIL_REGEXP"

    def validate_each(record, attribute, value)
      unless SPREE_EMAIL_REGEXP.match? value
        record.errors.add(attribute, :invalid, { value: value }.merge!(options))
      end
    end
  end
end
