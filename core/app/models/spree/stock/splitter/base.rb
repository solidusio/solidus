# frozen_string_literal: true

module Solidus
  module Stock
    module Splitter
      class Base
        attr_reader :stock_location, :next_splitter

        def initialize(stock_location_or_packer, next_splitter = nil)
          if stock_location_or_packer.is_a?(Solidus::StockLocation)
            @stock_location = stock_location_or_packer
          else
            Solidus::Deprecation.warn("Initializing Splitters with a Packer is DEPRECATED. Pass a StockLocation instead.")
            @stock_location = stock_location_or_packer.stock_location
          end
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
          Solidus::Stock::Package.new(stock_location, contents)
        end
      end
    end
  end
end
