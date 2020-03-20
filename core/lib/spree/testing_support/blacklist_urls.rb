# frozen_string_literal: true

module Spree
  module TestingSupport
    module BlacklistUrls
      def setup_url_blacklist(browser)
        if browser.respond_to?(:url_blacklist)
          browser.url_blacklist = ['http://fonts.googleapis.com']
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.before(:each, type: :feature) do
    setup_url_blacklist(page.driver.browser)
  end

  config.before(:each, type: :system) do
    setup_url_blacklist(page.driver.browser)
  end
end
