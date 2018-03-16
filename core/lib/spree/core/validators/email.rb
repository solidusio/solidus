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
      unless value =~ EMAIL_REGEXP
        record.errors.add(attribute, :invalid, { value: value }.merge!(options))
      end
    end
  end
end

# @private
EmailValidator = ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
  'EmailValidator',
  'Spree::EmailValidator',
  message: "EmailValidator is deprecated! Use Spree::EmailValidator instead.\nChange `validates :email, email: true` to `validates :email, 'spree/email' => true`\n"
)
