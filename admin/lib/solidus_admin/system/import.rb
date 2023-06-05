# frozen_string_literal: true

require "solidus_admin/container"

module SolidusAdmin
  # Auto-imports container dependencies.
  #
  # @example
  #   class Foo
  #     # Foo.new will have a `#bar` instance method that returns the
  #     # result of `Container["bar"]`.
  #     include Import["bar"]
  #   end
  Import = Container.injector
end
