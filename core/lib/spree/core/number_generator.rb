# frozen_string_literal: true

module Spree
  # Generates order numbers
  #
  # In order to change the way your order numbers get generated you can either
  # set your own instance of this class in your stores configuration with different options:
  #
  #     Spree::Config.order_number_generator = Spree::Core::NumberGenerator.new(
  #       prefix: 'B',
  #       lenght: 8,
  #       letters: false,
  #       model: Spree::Order
  #     )
  #
  #
  class Core::NumberGenerator
    attr_reader :letters, :prefix

    def initialize(options = {})
      @length = options[:length] || Spree::Order::ORDER_NUMBER_LENGTH
      @letters = options[:letters] || Spree::Order::ORDER_NUMBER_LETTERS
      @prefix = options[:prefix] || Spree::Order::ORDER_NUMBER_PREFIX
      @model = (options[:class_name] || 'Spree::Order').constantize
    end

    def generate
      possible = (0..9).to_a
      possible += ('A'..'Z').to_a if letters

      loop do
        # Make a random number.
        random = "#{prefix}#{Array.new(@length){ possible.sample }.join}"
        # Use the random number if no other order exists with it.

        if @model.exists?(number: random)
          # If over half of all possible options are taken add another digit.
          @length += 1 if @model.count > (10**@length / 2)
        else
          break random
        end
      end
    end
  end
end
