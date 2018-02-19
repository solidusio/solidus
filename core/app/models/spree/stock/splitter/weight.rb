# frozen_string_literal: true

module Spree
  module Stock
    module Splitter
      class Weight < Spree::Stock::Splitter::Base
        cattr_accessor :threshold do
          150
        end

        def split(packages)
          packages.each do |package|
            removed_contents = reduce package
            packages << build_package(removed_contents) unless removed_contents.empty?
          end
          return_next packages
        end

        private

        def reduce(package)
          removed = []
          while package.weight > threshold
            break if package.contents.size == 1
            removed << package.contents.shift
          end
          removed
        end
      end
    end
  end
end
