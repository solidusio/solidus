# frozen_string_literal: true

Solidus::Role.where(name: "admin").first_or_create
