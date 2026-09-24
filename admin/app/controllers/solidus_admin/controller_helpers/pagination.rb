# frozen_string_literal: true

module SolidusAdmin
  module ControllerHelpers
    module Pagination
      DEFAULT_PER_PAGE = 20

      def paginate(records, ordered_by: nil, per_page: DEFAULT_PER_PAGE)
        records.page(params[:page]).per(per_page)
      end

      def set_page_and_extract_portion_from(records, **options)
        Spree.deprecator.warn(
          "set_page_and_extract_portion_from is deprecated, use `@page = paginate(records, ...)` instead"
        )
        @page = paginate(records, **options)
      end
    end
  end
end
