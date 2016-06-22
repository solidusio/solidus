module Spree
  module Admin
    class ReportsController < Spree::Admin::BaseController
      respond_to :html

      class << self
        def available_reports
          @@available_reports
        end

        def add_available_report!(report_key, report_description_key = nil)
          if report_description_key.nil?
            report_description_key = "#{report_key}_description"
          end
          report_title = Spree.t("reports.#{report_key}")
          @@available_reports[report_key] = { name: Spree.t(report_key), description: report_description_key, title: report_title }
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
        report_class = "Spree::Reports::#{params[:id].camelize}".constantize
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
