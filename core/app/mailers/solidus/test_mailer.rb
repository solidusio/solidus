module Spree
  class TestMailer < BaseMailer
    def test_email(email)
      subject = "#{Solidus::Store.current.name} #{Solidus.t('test_mailer.test_email.subject')}"
      mail(to: email, from: from_address(Solidus::Store.current), subject: subject)
    end
  end
end
