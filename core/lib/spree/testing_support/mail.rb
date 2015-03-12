module Spree
  module TestingSupport
    module Mail
      def with_test_mail
        old_value = ActionMailer::Base.delivery_method
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.deliveries.clear
        begin
          yield
        ensure
          ActionMailer::Base.delivery_method = old_value
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.extend Spree::TestingSupport::Mail
end
