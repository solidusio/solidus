# frozen_string_literal: true

json.stores(@stores) { |store| json.partial!("spree/api/stores/store", store:) }
