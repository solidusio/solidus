# frozen_string_literal: true

module Spree
  module Stock
    class SplitterChain
      attr_reader :stock_location

      def initialize(stock_location, splitter_classes = [])
        @stock_location = stock_location
        @splitter_classes = splitter_classes
      end

      def split(initial_packages)
        initial_packages = Array(initial_packages)

        if @splitter_classes.empty?
          initial_packages
        else
          build_splitter.split(initial_packages)
        end
      end

      private

      def build_splitter
        splitter = nil
        @splitter_classes.reverse_each do |klass|
          splitter = klass.new(stock_location, splitter)
        end
        splitter
      end
    end
  end
end
