module Spree
  class BaseMailer < ActionMailer::Base
    def from_address(store = nil)
      if store
        store.mail_from_address
      else
        Spree::Deprecation.warn "A Spree::Store should be provided to determine the from address.", caller
        Spree::Config[:mails_from]
      end
    end

    def money(amount, currency = Spree::Config[:currency])
      Spree::Money.new(amount, currency: currency).to_s
    end
    helper_method :money

    def mail(headers = {}, &block)
      super if Spree::Config[:send_core_emails]
    end
  end
end
