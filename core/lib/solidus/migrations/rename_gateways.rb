# frozen_string_literal: true

module Solidus
  module Migrations
    class RenameGateways
      DEFAULT_MAPPING = {
        'Spree::Gateway' => 'Spree::PaymentMethod::CreditCard',
        'Spree::Gateway::Bogus' => 'Spree::PaymentMethod::BogusCreditCard',
        'Spree::Gateway::BogusSimple' => 'Spree::PaymentMethod::SimpleBogusCreditCard'
      }

      attr_reader :gateway_mapping

      def initialize(gateway_mapping = DEFAULT_MAPPING)
        Spree::Deprecation.warn 'Solidus::Migrations::RenameGateways is deprecated and will be removed with Solidus 3.0.'

        @gateway_mapping = gateway_mapping
      end

      def up
        gateway_mapping.inject(0) do |count, mapping|
          count + update(from: mapping[0], to: mapping[1])
        end
      end

      def down
        gateway_mapping.inject(0) do |count, mapping|
          count + update(from: mapping[1], to: mapping[0])
        end
      end

      private

      def update(from:, to:)
        ActiveRecord::Base.connection.update <<-SQL.strip_heredoc
          UPDATE spree_payment_methods SET type = '#{to}' WHERE type = '#{from}';
        SQL
      end
    end
  end
end
