# frozen_string_literal: true

module Spree
  module TestingSupport
    module Translations
      def check_missing_translations(page, example)
        missing_translations = page.body.scan(/translation missing: #{I18n.locale}\.(.*?)[\s<"&]/)
        if missing_translations.any?
          Rails.logger.info "Found missing translations: #{missing_translations.inspect}"
          Rails.logger.info "In spec: #{example.location}"
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.after(:each, type: :feature) do |example|
    check_missing_translations(page, example)
  end

  config.after(:each, type: :system) do |example|
    check_missing_translations(page, example)
  end
end
