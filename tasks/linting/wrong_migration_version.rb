# frozen_string_literal: true

require_relative "../../core/lib/spree/core/version"

module Solidus
  class WrongMigrationVersion < RuboCop::Cop::Base
    MSG = "Subclasses of ActiveRecord::Migration must use a migration version " \
      "of <= #{Spree.minimum_required_rails_version}"

    def on_class(node)
      return unless (superclass = node.parent_class)
      return unless superclass.source&.start_with?("ActiveRecord::Migration")
      return unless (given_version_arg = superclass.arguments.first&.value)

      unless meets_solidus_minimum_required_rails_version? given_version_arg
        add_offense node, message: MSG
      end
    end

    private

    def meets_solidus_minimum_required_rails_version?(version_argument)
      Gem::Version.new(version_argument) <=
        Gem::Version.new(Spree.minimum_required_rails_version)
    end
  end
end
