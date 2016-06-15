module Spree
  module Reports
    # Sales total for all orders in a given period
    class SalesTotal
      def self.description
        Spree.t("reports.sales_total_description")
      end

      def self.template
        "spree/admin/reports/sales_total"
      end

      def initialize(params)
        params[:q] = {} unless params[:q]

        if params[:q][:completed_at_gt].blank?
          params[:q][:completed_at_gt] = Time.current.beginning_of_month
        else
          params[:q][:completed_at_gt] = begin
                                           Time.zone.parse(params[:q][:completed_at_gt]).beginning_of_day
                                         rescue
                                           Time.current.beginning_of_month
                                         end
        end

        if params[:q] && !params[:q][:completed_at_lt].blank?
          params[:q][:completed_at_lt] = begin
                                           Time.zone.parse(params[:q][:completed_at_lt]).end_of_day
                                         rescue
                                           ""
                                         end
        end

        params[:q][:s] ||= "completed_at desc"

        @search = Order.complete.ransack(params[:q])
        @orders = @search.result

        @totals = {}
        @orders.each do |order|
          unless @totals[order.currency]
            @totals[order.currency] = {
              item_total: ::Money.new(0, order.currency),
              adjustment_total: ::Money.new(0, order.currency),
              sales_total: ::Money.new(0, order.currency)
            }
          end

          @totals[order.currency][:item_total] += order.display_item_total.money
          @totals[order.currency][:adjustment_total] += order.display_adjustment_total.money
          @totals[order.currency][:sales_total] += order.display_total.money
        end
      end

      def locals
        {
          search: @search,
          totals: @totals
        }
      end
    end
  end
end
