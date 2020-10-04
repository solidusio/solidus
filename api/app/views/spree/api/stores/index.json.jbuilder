# frozen_string_literal: true

json.stores(@stores) { |store| json.(store, *store_attributes) }
