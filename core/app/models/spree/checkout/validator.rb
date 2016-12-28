##
#
# Then we can access to this errors in the shared partial
# "_error_messages" like standard rails errors:
# <% target.checkout_validator.errors.full_messages.each do |msg| %>
#   <li><%= msg %></li>
# <% end unless target.checkout_validator.errors.empty? %>
#
#
module Spree::Checkout

  # Validation class for stop the Order to start the checkout
  #
  # @example Print validations in views
  # We can access to this errors in the shared partial
  # "_error_messages" like standard rails errors:
  # <% target.checkout_validator.errors.full_messages.each do |msg| %>
  #   <li><%= msg %></li>
  # <% end unless target.checkout_validator.errors.empty? %>
  #
  # @author Marino Bonetti
  # @attr [Spree::Order] order a full description of the attribute
  # @attr [ActiveModel::Errors] errors collection of errors on the checkout
  #
  class Validator

    attr_accessor :errors
    attr_accessor :order

    def initialize(order)
      @order = order
      self.errors = ActiveModel::Errors.new(order)
    end

    # Check if Order can start checkout
    #
    # @return [true,false] if we can start
    #
    def can_start?
      Spree::Config.checkout_blockers.any? { |blocker| blocker.new(@order).blocks_checkout? }
    end

    # Helper method to return all invalid blocks errors
    #
    # @return [ActiveModel::Errors] return an instance filled with errors
    #
    def checkout_blocker_errors
      self.errors.clear
      Spree::Config.checkout_blockers.each do |blocker|
        if blocker.new(@order).blocks_checkout?
          self.errors.add(@order, blocker)
        end
      end
      self.errors
    end


    # after_initialize :validate_solidus_checkout
    #
    # #virtual attribute to contain the checkout errors
    # attr_accessor :_checkout_errors
    #
    # # def checkout_allowed?
    # #   line_items.count > 0 and self.checkout_errors.empty?
    # # end
    #
    #
    # def checkout_errors
    #   if self._checkout_errors.nil?
    #     self._checkout_errors = ActiveModel::Errors.new(self)
    #   end
    #   self._checkout_errors
    # end
    #
    # def validate_solidus_checkout
    #   self.valid?(:solidus_checkout)
    # end
    #
    #
    # ##
    # # validation on context of solidus checkout, that don't will interest the
    # # real validation of record, but only stop checkout and be able to see
    # # errors for the checkout
    # def self.checkout_validate(*args, &block)
    #
    #   options = args.extract_options!
    #
    #   #append my validation context
    #   on = [options[:on]||[]].flatten
    #   on<<:solidus_checkout
    #   options[:on]=on
    #
    #   args<<options
    #
    #   validate *args, &block
    #
    # end

  end
end
