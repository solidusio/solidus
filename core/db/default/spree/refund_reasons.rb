# frozen_string_literal: true

Solidus::RefundReason.find_or_create_by!(name: "Return processing", mutable: false)
