namespace :email do
  desc 'Sends test email to specified address - Example: EMAIL=spree@example.com bundle exec rake email:test'
  task test: :environment do
    raise ArgumentError, "Must pass EMAIL environment variable. Example: EMAIL=spree@example.com bundle exec rake email:test" unless ENV['EMAIL'].present?
    Spree::TestMailer.test_email(ENV['EMAIL']).deliver!
  end
end
