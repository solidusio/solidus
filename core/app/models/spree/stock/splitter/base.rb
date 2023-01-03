# frozen_string_literal: true

module Spree
  module Stock
    module Splitter
      class Base
        attr_reader :stock_location, :next_splitter

        def initialize(stock_location, next_splitter = nil)
          @stock_location = stock_location
          @next_splitter = next_splitter
        end

        def split(packages)
          return_next(packages)
        end

        private

        def return_next(packages)
          next_splitter ? next_splitter.split(packages) : packages
        end

        def build_package(contents = [])
          Spree::Stock::Package.new(stock_location, contents)
        end
      end
    end
  end
end

