# frozen_string_literal: true

module Solidus
  class TestMailer < BaseMailer
    def test_email(email)
      Solidus::Deprecation.warn("Solidus::TestMailer has been deprecated and will be removed with Solidus 3.0")

      store = Solidus::Store.default
      subject = "#{store.name} #{t('.subject')}"
      mail(to: email, from: from_address(store), subject: subject)
    end
  end
end
