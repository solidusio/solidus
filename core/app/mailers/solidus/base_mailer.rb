module Solidus
  class BaseMailer < ActionMailer::Base

    def from_address(store = nil)
      if store
        store.mail_from_address
      else
        ActiveSupport::Deprecation.warn "A Solidus::Store should be provided to determine the from address.", caller
        Solidus::Config[:mails_from]
      end
    end

    def money(amount, currency = Solidus::Config[:currency])
      Solidus::Money.new(amount, currency: currency).to_s
    end
    helper_method :money

    def mail(headers={}, &block)
      super if Solidus::Config[:send_core_emails]
    end

  end
end
