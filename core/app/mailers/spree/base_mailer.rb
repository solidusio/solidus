module Spree
  class BaseMailer < ActionMailer::Base
    def from_address(store = nil)
      if store
        store.mail_from_address
      else
        ActiveSupport::Deprecation.warn "A Spree::Store should be provided to determine the from address.", caller
        Spree::Config[:mails_from]
      end
    end

    def money(amount, currency = Spree::Config[:currency])
      Spree::Money.new(amount, currency: currency).to_s
    end
    helper_method :money

    def mail(headers = {}, &block)
      if Spree::Config[:send_core_emails]
        super
      else
        ActiveSupport::Deprecation.warn "Not sending mail due to `Spree::Config[:send_core_emails]`. This check will be removed from Spree::BaseMailer in the future, please use Spree::NotificationDispatch#deliver instead.", caller
      end
    end
  end
end
