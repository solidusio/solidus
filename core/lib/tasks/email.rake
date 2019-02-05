# frozen_string_literal: true

namespace :email do
  desc 'Sends test email to specified address - Example: EMAIL=spree@example.com bundle exec rake email:test'
  task test: :environment do
    Spree::Deprecation.warn("rake email:test has been deprecated and will be removed with Solidus 3.0")

    raise ArgumentError, "Must pass EMAIL environment variable. Example: EMAIL=spree@example.com bundle exec rake email:test" unless ENV['EMAIL'].present?
    Spree::TestMailer.test_email(ENV['EMAIL']).deliver!
  end
end
