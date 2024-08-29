# frozen_string_literal: true

json.stores(@stores) { |store| json.call(store, *store_attributes) }
