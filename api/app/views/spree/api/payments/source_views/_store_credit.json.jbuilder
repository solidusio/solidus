# frozen_string_literal: true

json.call(payment_source, :id, :memo, :created_at)
json.created_by payment_source.created_by.email
json.category payment_source.category, :id, :name
