class MigrateOldPreferences < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    migrate_preferences(Spree::Calculator)
    migrate_preferences(Spree::PromotionRule)
    migrate_preferences(Spree::PaymentMethod)
  end

  def down
  end

  private

  def migrate_preferences(klass)
    klass.reset_column_information
    klass.find_in_batches do |batch|
      ActiveRecord::Base.transaction do
        batch.each do |record|
          keys = record.class.defined_preferences

          # Batch load preferences for this record.
          preferences = Hash[Spree::Preference.where(
            key: keys.map{ |k| cache_key(record, k) }
          ).pluck(:key, :value)]

          # Copy preferences to the record.
          keys.each do |key|
            value = preferences[cache_key(record, key)]
            record.preferences[key] = value unless value.nil?
          end

          # Persist the preferences.
          record.update_column(:preferences, record.preferences)
        end
      end
    end
  end

  def cache_key(model, key)
    [
      ENV["RAILS_CACHE_ID"],
      class_underscore_cache[model.type],
      key,
      model.id
    ].compact.join("/")
  end

  def class_underscore_cache
    @class_underscore_cache ||= Hash.new{ |h, k| h[k] = k.underscore }
  end
end
