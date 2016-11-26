require 'active_support/concern'


##
# This Concern give the ability to make validation of the
# Order model with standard rails ActiveRecord::Validation
# whithout stop saving that.
#
# Example of a validation:
#
#
# app/model/concerns/order_concern.rb
#
# require 'active_support/concern'
#
# module OrderConcern
#   extend ActiveSupport::Concern
#   # include CheckoutValidatorConcern
#
#   included do
#
#     checkout_validate :check_min_order
#
#     def check_min_order
#       if self.line_items.map(&:amount).sum<100
#         self.checkout_errors.add(:base, :min_order, :minimum => 100)
#       end
#     end
#
#   end
#
# end
#
#
# app/models/spree/order_decorator
#
# Spree::Order.include OrderConcern
#
#

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
