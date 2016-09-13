module Spree
  class TestMailer < BaseMailer
    def test_email(email)
      store = Spree::Store.default
      subject = "#{store.name} #{Spree.t('test_mailer.test_email.subject')}"
      mail(to: email, from: from_address(store), subject: subject)
    end
  end
end
