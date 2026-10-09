# frozen_string_literal: true

module SolidusAdmin
  module ControllerHelpers
    module Pagination
      DEFAULT_PER_PAGE = 20

      def paginate(records, ordered_by: nil, per_page: DEFAULT_PER_PAGE)
        records.page(params[:page]).per(per_page)
      end
    end
  end
end
