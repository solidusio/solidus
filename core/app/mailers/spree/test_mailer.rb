# frozen_string_literal: true

module Spree
  class TestMailer < BaseMailer
    def test_email(email)
      store = Spree::Store.default
      subject = "#{store.name} #{t('.subject')}"
      mail(to: email, from: from_address(store), subject: subject)
    end
  end
end
