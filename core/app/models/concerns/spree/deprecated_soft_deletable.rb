# core/app/models/concerns/spree/deprecated_soft_deletable.rb

module Spree
  module DeprecatedSoftDeletable
    extend ActiveSupport::Concern

    SOFT_DELETE_DEPRECATION_MSG = ->(method, suggestion) {
      "`Spree::Price##{method}` is deprecated and will be removed in a future version of Solidus. #{suggestion}"
    }.freeze

    included do
      scope :kept, -> {
        Spree.deprecator.warn(
          SOFT_DELETE_DEPRECATION_MSG.call(
            "kept",
            "Filter by variant availability via `joins(:variant).merge(Spree::Variant.kept)` instead."
          )
        )
        unscope(where: :deleted_at).where(deleted_at: nil)
      }

      scope :discarded, -> {
        Spree.deprecator.warn(
          SOFT_DELETE_DEPRECATION_MSG.call(
            "discarded",
            "There will be no discarded prices once the deleted_at column is removed."
          )
        )
        unscoped.where.not(deleted_at: nil)
      }

      scope :with_discarded, -> {
        Spree.deprecator.warn(
          SOFT_DELETE_DEPRECATION_MSG.call(
            "with_discarded",
            "After removal, all prices will be returned by default without filtering."
          )
        )
        unscoped
      }
    end

    INSTANCE_METHOD_SUGGESTIONS = {
      discard: "Discard the parent variant with `variant.discard` instead.",
      discard!: "Discard the parent variant with `variant.discard!` instead.",
      undiscard: "Prices will not be individually soft-deleted; this has no equivalent.",
      undiscard!: "Prices will not be individually soft-deleted; this has no equivalent.",
      discarded?: "Check the parent variant's discarded state with `variant.discarded?` instead.",
      kept?: "Check the parent variant's kept state with `variant.kept?` instead."
    }.freeze

    INSTANCE_METHOD_SUGGESTIONS.each_key do |m|
      define_method(m) do
        Spree.deprecator.warn(
          SOFT_DELETE_DEPRECATION_MSG.call(m, INSTANCE_METHOD_SUGGESTIONS[m])
        )
        super()
      end
    end
  end
end
