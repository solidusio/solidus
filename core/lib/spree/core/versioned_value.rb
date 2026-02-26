# frozen_string_literal: true

module Spree
  module Core
    # Wrapper for a value that can be different depending on the Solidus version
    #
    # Some configuration defaults can be added or changed when a new Solidus
    # version is released. This class encapsulates getting the correct value for a
    # given Solidus version.
    #
    # The way it works is you provide an initial value in time, plus the version
    # boundary where it got changed. Then you can fetch the value providing the
    # desired Solidus version:
    #
    # @example
    #   value = VersionedValue.new(true, "3.0.0" => false)
    #   value.call("2.7.0") # => true
    #   value.call("3.0.0") # => false
    #   value.call("3.1.0") # => false
    #
    # Remember that you must provide the exact boundary when a value got changed,
    # which could easily be during a pre-release:
    #
    # @example
    #   value = VersionedValue.new(true, "3.0.0" => false)
    #   value.call("3.0.0.alpha") # => true
    #
    #   value = VersionedValue.new(true, "3.0.0.alpha" => false)
    #   value.call("3.0.0.alpha") # => false
    #
    # Multiple boundaries can also be provided:
    #
    # @example
    #   value = VersionedValue.new(0, "2.0.0" => 1, "3.0.0" => 2)
    #   value.call("1.0.0") # => 0
    #   value.call("2.1.0") # => 1
    #   value.call("3.0.0") # => 2
    class VersionedValue
      attr_reader :boundaries

      # @param initial_value [Any]
      # @param boundary [Hash<String, Any>] Map from version number to new value
      def initialize(initial_value, boundaries = {})
        @boundaries = {"0" => initial_value}
          .merge(boundaries)
          .transform_keys { |version| to_gem_version(version) }
          .sort.to_h
      end

      # @param solidus_version [String]
      def call(solidus_version = Spree.solidus_version)
        solidus_version = to_gem_version(solidus_version)
        boundaries.fetch(
          boundaries
            .keys
            .reduce do |target, following|
              if target <= solidus_version && solidus_version < following
                target
              else
                following
              end
            end
        )
      end

      private

      def to_gem_version(string)
        Gem::Version.new(string)
      end
    end
  end
end
