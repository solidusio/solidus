# frozen_string_literal: true

Spree::Role.where(name: "admin").first_or_create
