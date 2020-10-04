# frozen_string_literal: true

module Spree
  # Generates order numbers
  #
  # In order to change the way your order numbers get generated you can either
  # set your own instance of this class in your stores configuration with different options:
  #
  #     Spree::Config.order_number_generator = Spree::Order::NumberGenerator.new(
  #       prefix: 'B',
  #       lenght: 8,
  #       letters: false
  #     )
  #
  # or create your own class:
  #
  #     Spree::Config.order_number_generator = My::OrderNumberGenerator.new
  #
  class Order::NumberGenerator
    attr_reader :letters, :prefix

    def initialize(options = {})
      @length = options[:length] || Spree::Order::ORDER_NUMBER_LENGTH
      @letters = options[:letters] || Spree::Order::ORDER_NUMBER_LETTERS
      @prefix = options[:prefix] || Spree::Order::ORDER_NUMBER_PREFIX
    end

    def generate
      possible = (0..9).to_a
      possible += ('A'..'Z').to_a if letters

      loop do
        # Make a random number.
        random = "#{prefix}#{(0...@length).map { possible.sample }.join}"
        # Use the random number if no other order exists with it.
        if Spree::Order.exists?(number: random)
          # If over half of all possible options are taken add another digit.
          @length += 1 if Spree::Order.count > (10**@length / 2)
        else
          break random
        end
      end
    end
  end
end
