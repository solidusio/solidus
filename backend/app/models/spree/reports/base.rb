module Spree
  module Reports
    # Parent class for reports
    class Base
      include ActionView::Helpers::UrlHelper

      def self.description
        description_key = "reports.#{name.demodulize.underscore}_description"
        Spree.t(description_key)
      end

      def self.template
        "spree/admin/reports/table_report"
      end

      def initialize(_params)
        raise NotImplementedError, Spree.t("reports.implement_initialize")
      end

      def content
        raise NotImplementedError, Spree.t("reports.content")
      end

      private

      def spree_routes
        Spree::Core::Engine.routes.url_helpers
      end

      def parse_date_param(datestr)
        Time.zone.parse(datestr)
      end
    end
  end
end
