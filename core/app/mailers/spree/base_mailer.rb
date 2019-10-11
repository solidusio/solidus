# frozen_string_literal: true

module Solidus
  class BaseMailer < ActionMailer::Base
    def from_address(store)
      store.mail_from_address
    end

    def money(amount, currency = Solidus::Config[:currency])
      Solidus::Money.new(amount, currency: currency).to_s
    end
    helper_method :money

    def mail(headers = {}, &block)
      super if Solidus::Config[:send_core_emails]
    end
  end
end
