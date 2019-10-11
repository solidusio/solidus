# frozen_string_literal: true

namespace :email do
  desc 'Sends test email to specified address - Example: EMAIL=spree@example.com bundle exec rake email:test'
  task test: :environment do
    Solidus::Deprecation.warn("rake email:test has been deprecated and will be removed with Solidus 3.0")

    raise ArgumentError, "Must pass EMAIL environment variable. Example: EMAIL=spree@example.com bundle exec rake email:test" unless ENV['EMAIL'].present?
    Solidus::TestMailer.test_email(ENV['EMAIL']).deliver!
  end
end
