# frozen_string_literal: true

module Spree
  module Preferences
    class StaticModelPreferences
      class Definition
        attr_reader :preferences

        def initialize(klass, hash)
          @klass = klass
          @preferences = hash.symbolize_keys
        end

        def fetch(key, &block)
          @preferences.fetch(key, &block)
        end

        def []=(key, value)
          # ignores assignment
        end

        def to_hash
          @preferences.deep_dup
        end

        delegate :keys, to: :@preferences
      end

      def initialize
        @store = Hash.new do |data, klass|
          data[klass] = {}
        end
      end

      def add(klass, name, preferences)
        @store[klass.to_s][name] = Definition.new(klass.to_s, preferences)
      end

      def for_class(klass)
        @store[klass.to_s]
      end

      def validate!
        @store.keys.map(&:constantize).each do |klass|
          validate_for_class!(klass)
        end
      end

      private

      def validate_for_class!(klass)
        for_class(klass).each do |name, preferences|
          klass_keys = klass.defined_preferences.map(&:to_s)
          extra_keys = preferences.keys.map(&:to_s) - klass_keys
          next if extra_keys.empty?

          raise \
            "Unexpected keys found for #{klass} under #{name}: #{extra_keys.sort.join(', ')} " \
            "(expected keys: #{klass_keys.sort.join(', ')})"
        end
      end
    end
  end
end
