# frozen_string_literal: true

json.success(@handler.success)
json.errors(@handler.errors.details[:base])
json.successful(@handler.successful?)
