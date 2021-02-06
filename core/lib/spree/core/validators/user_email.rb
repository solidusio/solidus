# frozen_string_literal: true

require_relative 'email'

module Spree
  # === Spree::EmailValidator subclass which uses the format validator of an associated :user
  #
  # === Usage
  #
  #     require 'spree/core/validators/devise_email'
  #
  #     class Order < ApplicationRecord
  #       belongs_to :user, optional: true
  #       validates :email_address, 'spree/devise_email' => true
  #     end
  #
  # If the record contains a :user association, it will reflect on that association and use
  # its format validator, if present, to validate the email. Otherwise, validation will be delegated to
  # Spree::EmailValidator
  #
  class UserEmailValidator < EmailValidator
    def validate_each(record, attribute, value)
      user_format_validator = user_email_format_validator(record)

      if user_format_validator.is_a? ActiveModel::EachValidator
        user_format_validator.validate_each record, attribute, value
        return
      end

      super
    end

    protected

    def user_email_format_validator(record)
      user_association = record.class.reflect_on_association(:user)

      if user_association
        email_validators = user_association.klass.validators_on :email

        return if email_validators.blank?

        format_validators = email_validators.select { |validator| validator.kind == :format }

        # possible improvement: should we care about multiple format validators?
        format_validators.first
      end
    end
  end
end
