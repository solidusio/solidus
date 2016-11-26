require 'active_support/concern'

module Spree
  module CheckoutValidator
    extend ActiveSupport::Concern

    included do
      after_initialize :validate_solidus_checkout

      #virtual attribute to contain the checkout errors
      attr_accessor :_checkout_errors

      # def checkout_allowed?
      #   line_items.count > 0 and self.checkout_errors.empty?
      # end


      def checkout_errors
        if self._checkout_errors.nil?
          self._checkout_errors = ActiveModel::Errors.new(self)
        end
        self._checkout_errors
      end

      def validate_solidus_checkout
        self.valid?(:solidus_checkout)
      end

    end

    module ClassMethods

      ##
      # validation on context of solidus checkout, that don't will interest the
      # real validation of record, but only stop checkout and be able to see
      # errors for the checkout
      def checkout_validate(*args, &block)

        options = args.extract_options!

        #append my validation context
        on = [options[:on]||[]].flatten
        on<<:solidus_checkout
        options[:on]=on

        args<<options

        validate *args, &block

      end


    end
  end
end
