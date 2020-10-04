# frozen_string_literal: true

module Spree
  class TestMailer < BaseMailer
    def test_email(email)
      Spree::Deprecation.warn("Spree::TestMailer has been deprecated and will be removed with Solidus 3.0")

      store = Spree::Store.default
      subject = "#{store.name} #{t('.subject')}"
      mail(to: email, from: from_address(store), subject: subject)
    end
  end
end
