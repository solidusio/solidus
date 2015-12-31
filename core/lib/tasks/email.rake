namespace :email do
  desc 'Sends test email to specified address - Example: EMAIL=solidus@example.com bundle exec rake test:email'
  task :test => :environment do
    raise ArgumentError, "Must pass EMAIL environment variable. Example: EMAIL=solidus@example.com bundle exec rake test:email" unless ENV['EMAIL'].present?
    Solidus::TestMailer.test_email(ENV['EMAIL']).deliver!
  end
end
