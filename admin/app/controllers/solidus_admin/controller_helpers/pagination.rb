# frozen_string_literal: true

module SolidusAdmin
  module ControllerHelpers
    module Pagination
      DEFAULT_PER_PAGE = 20

      def paginate(records, ordered_by: nil, per_page: DEFAULT_PER_PAGE)
        records = records.order(with_primary_key_tiebreaker(records, ordered_by)) if ordered_by
        records.page(params[:page]).per(per_page)
      end

      def set_page_and_extract_portion_from(records, **options)
        Spree.deprecator.warn(
          "set_page_and_extract_portion_from is deprecated, use `@page = paginate(records, ...)` instead"
        )
        @page = paginate(records, **options)
      end

      private

      # Offset pagination needs a unique sort, or rows with equal values (e.g. two
      # products with the same name) can repeat or go missing across pages.
      def with_primary_key_tiebreaker(records, ordered_by)
        ordered_by = ordered_by.to_h.symbolize_keys
        primary_key = records.klass.primary_key.to_sym
        return ordered_by if ordered_by.key?(primary_key)

        ordered_by.merge(primary_key => ordered_by.values.last)
      end
    end
  end
end
