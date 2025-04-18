# frozen_string_literal: true

module Spree
  module Admin
    class SearchController < Spree::Admin::BaseController
      respond_to :json
      layout false

      # TODO: Clean this up by moving searching out to user_class_extensions
      # And then JSON building with something like Active Model Serializers
      def users
        if params[:ids]
          # split here may be String#split or Array#split, so we must flatten the results
          @users = Spree.user_class.where(id: params[:ids].split(',').flatten)
        else
          @users = Spree.user_class.ransack({
            m: 'or',
            email_start: params[:q],
            name_start: params[:q],
            addresses_firstname_start: params[:q],
            addresses_lastname_start: params[:q]
          }).result.limit(10)
        end
      end

      def products
        if params[:ids]
          # split here may be String#split or Array#split, so we must flatten the results
          @products = Spree::Product.where(id: params[:ids].split(",").flatten)
        else
          @products = Spree::Product.ransack(params[:q]).result
        end

        @products = list_products
        expires_in 15.minutes, public: true
        headers['Surrogate-Control'] = "max-age=#{15.minutes}"
      end

      private

      def list_products
        if params[:show_all]
          @products.distinct.page(params[:page])
        else
          @products.distinct.page(params[:page]).per(params[:per_page])
        end
      end
    end
  end
end
