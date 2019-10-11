# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    EXTENSIONS = [
      ModelNaming,
      TablePrefix,
      SpreeConstant,
      ControllerViewPaths,
      MailerViewPaths,
      ControllerBelongsTo,
      CustomValidationsI18n,
      ModelPartialPaths,
    ].freeze

    def self.activate
      EXTENSIONS.each(&:activate)
    end
  end
end

[
  Solidus::NamespaceMigration::SpreeConstant
].each(&:activate)
