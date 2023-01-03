# frozen_string_literal: true

module Spree
  module Preferences
    class StaticModelPreferences
      class Definition
        attr_reader :preferences

        def initialize(klass, hash)
          hash = hash.symbolize_keys
          hash.keys.each do |key|
            if !klass.defined_preferences.include?(key)
              raise "Preference #{key.inspect} is not defined on #{klass}"
            end
          end
          @preferences = hash
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
      end

      def initialize
        @store = Hash.new do |data, klass|
          data[klass] = {}
        end
      end

      def add(klass, name, preferences)
        @store[klass.to_s][name] = Definition.new(klass, preferences)
      end

      def for_class(klass)
        @store[klass.to_s]
      end
    end
  end
end

