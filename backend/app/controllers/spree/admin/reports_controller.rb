module Spree
  module Admin
    class ReportsController < Spree::Admin::BaseController
      respond_to :html

      class << self
        def available_reports
          @@available_reports
        end

        def add_available_report!(report_key, report_description = nil)
          if report_description.nil?
            report_description = Spree.t("reports.#{report_key}_description")
          end
          @@available_reports[report_key] = {
            name: Spree.t("reports.#{report_key}"),
            description: report_description
          }
        end
      end

      def initialize
        super
        Rails.application.config.spree.reports.each do |report|
          Spree::Admin::ReportsController.add_available_report!(
            report.name.demodulize.underscore.to_sym,
            report.description
          )
        end
      end

      def index
        @reports = ReportsController.available_reports
      end

      def show
        report_class = "Spree::Report::#{params[:id].camelize}".constantize
        report = report_class.new(params)
        respond_to do |format|
          format.html do
            report.content.each do |key, value|
              instance_variable_set("@#{key}", value)
            end
            render report_class.template
          end
        end
      end

      @@available_reports = {}
    end
  end
end
