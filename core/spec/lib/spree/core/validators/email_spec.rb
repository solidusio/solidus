# frozen_string_literal: true

require 'rails_helper'
require 'spree/core/validators/email'

RSpec.describe Spree::EmailValidator do
  class Tester
    include ActiveModel::Validations
    attr_accessor :email_address
    validates :email_address, 'spree/email' => true
  end

  let(:valid_emails) {
    [
      'valid@email.com',
      'valid@email.com.uk',
      'e@email.com',
      'valid+email@email.com',
      'valid-email@email.com',
      'valid_email@email.com',
      'valid.email@email.com'
    ]
  }
  let(:invalid_emails) {
    [
      'invalid email@email.com',
      '@email.com',
      'invalidemailemail.com',
      '@invalid.email@email.com',
      'invalid@email@email.com',
      'invalid.email@@email.com'
    ]
  }

  it 'validates valid email addresses', :aggregate_failures do
    tester = Tester.new
    valid_emails.each do |email|
      tester.email_address = email
      expect(tester.valid?).to be(true), "expected #{email} to be valid"
    end
  end

  it 'validates invalid email addresses', :aggregate_failures do
    tester = Tester.new
    invalid_emails.each do |email|
      tester.email_address = email
      expect(tester.valid?).to be(false), "expected #{email} not to be valid"
    end
  end
end
