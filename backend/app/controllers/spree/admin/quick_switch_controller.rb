# frozen_string_literal: true

module Spree
  module Admin
    class QuickSwitchController < Spree::Admin::BaseController
      layout false

      def find_object
        quick_switch_item = Spree::Backend::Config.quick_switch_items.detect do |item|
          item.search_triggers.include? searched_key.to_sym
        end

        if quick_switch_item
          if object = quick_switch_item.finder.call(searched_value)
            render(
              json: {
                redirect_url: quick_switch_item.url.call(object)
              },
              status: :ok
            )
          else
            render(
              json: {
                message: quick_switch_item.not_found_text(searched_value)
              },
              status: :not_found
            )
          end
        else
          render(
            json: {
              message: I18n.t("invalid_query", scope: "spree.quick_switch")
            },
            status: :bad_request
          )
        end
      end

      private

      def searched_key
        params[:quick_switch_query].split(" ")[0]
      end

      def searched_value
        params[:quick_switch_query].split(" ")[1]
      end
    end
  end
end
