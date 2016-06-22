module Spree
  module Report
    # Sales total for all orders in a given period
    class SalesTotal < Base
      def self.template
        "spree/admin/reports/sales_total"
      end

      def initialize(params)
        params[:q] = {} unless params[:q]
        params[:q][:completed_at_gt] = parse_start_time(params[:q][:completed_at_gt])
        if params[:q] && !params[:q][:completed_at_lt].blank?
          params[:q][:completed_at_lt] = parse_end_time(params[:q][:completed_at_lt])
        end
        params[:q][:s] ||= "completed_at desc"
        @ransack_query = params[:q]
      end

      def content
        search = Order.complete.ransack(@ransack_query)
        {
          search: search,
          totals: totals(search.result)
        }
      end

      private

      def parse_start_time(start_time)
        return Time.current.beginning_of_month if start_time.blank?
        Time.zone.parse(start_time).beginning_of_day
      rescue
        Time.current.beginning_of_month
      end

      def parse_end_time(end_time)
        Time.zone.parse(end_time).end_of_day
      rescue
        ""
      end

      def totals(orders)
        totals = {}
        orders.each do |order|
          currency = order.currency
          totals[currency] ||= zero_currency_total(currency)
          totals[currency][:item_total] += order.display_item_total.money
          totals[currency][:adjustment_total] += order.display_adjustment_total.money
          totals[currency][:sales_total] += order.display_total.money
        end
        totals
      end

      def zero_currency_total(currency)
        {
          item_total: ::Money.new(0, currency),
          adjustment_total: ::Money.new(0, currency),
          sales_total: ::Money.new(0, currency)
        }
      end
    end
  end
end
