# frozen_string_literal: true

# Use singleton class Spree::Preferences::Store.instance to access
#

require "singleton"

module Spree::Preferences
  class StoreInstance
    def initialize
      @cache = Rails.cache
    end

    def set(key, value)
      @cache.write(key, value)
      persist(key, value)
    end
    alias_method :[]=, :set

    def exist?(key)
      @cache.exist?(key) ||
        should_persist? && Spree::Preference.where(key:).exists?
    end

    def get(key)
      # return the retrieved value, if it's in the cache
      # use unless nil? incase the value is actually boolean false
      #
      unless (val = @cache.read(key)).nil?
        return val
      end

      if should_persist?
        # If it's not in the cache, maybe it's in the database, but
        # has been cleared from the cache

        # does it exist in the database?
        val = if preference = Spree::Preference.find_by(key:)
          # it does exist
          preference.value
        else
          # use the fallback value
          yield
        end

        # Cache either the value from the db or the fallback value.
        # This avoids hitting the db with subsequent queries.
        @cache.write(key, val)

        val
      else
        yield
      end
    end
    alias_method :fetch, :get

    def delete(key)
      @cache.delete(key)
      destroy(key)
    end

    def clear_cache
      @cache.clear
    end

    private

    def persist(cache_key, value)
      return unless should_persist?

      preference = Spree::Preference.where(key: cache_key).first_or_initialize
      preference.value = value
      preference.save
    end

    def destroy(cache_key)
      return unless should_persist?

      preference = Spree::Preference.find_by(key: cache_key)
      preference&.destroy
    end

    def should_persist?
      Spree::Preference.table_exists?
    end
  end

  class Store < StoreInstance
    include Singleton
  end
end
