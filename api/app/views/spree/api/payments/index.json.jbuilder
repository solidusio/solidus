# frozen_string_literal: true

json.payments(@payments) { |payment| json.(payment, *payment_attributes) }
json.partial! 'spree/api/shared/pagination', pagination: @payments
