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
      super if should_send_mail?
    end

    private

    def should_send_mail?
      pref = Spree::Config[:send_core_emails]

      if pref == true || pref == false
        return pref
      end

      # let preference be expressed without the Spree:: prefix for convenience
      class_names = [self.class.name.sub(/\ASpree::/, ''), self.class.name]

      if pref[:only].present? && (pref[:only] & class_names).empty?
        return false
      end

      if pref[:except].present? && (pref[:except] & class_names).present?
        return false
      end

      !!pref
    end
  end
end
