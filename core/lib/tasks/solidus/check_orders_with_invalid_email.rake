# frozen_string_literal: true

namespace :solidus do
  desc 'Prints orders with invalid email (after fix for GHSA-qxmr-qxh6-2cc9)'
  task check_orders_with_invalid_email: :environment do
    matches = Spree::Order.find_each.reduce([]) do |matches, order|
      order.email.nil? || Spree::EmailValidator::EMAIL_REGEXP.match?(order.email) ? matches : matches + [order]
    end
    if matches.any?
      puts 'Email / ID / Number'
      puts(matches.map do |order|
        "#{order.email} / #{order.id} / #{order.number}"
      end.join("\n"))
    else
      puts 'NO MATCHES'
    end
  end
end

