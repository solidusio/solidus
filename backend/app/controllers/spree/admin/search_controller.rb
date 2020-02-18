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
            firstname_or_lastname_start: params[:q]
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

        @products = @products.distinct.page(params[:page]).per(params[:per_page])
        expires_in 15.minutes, public: true
        headers['Surrogate-Control'] = "max-age=#{15.minutes}"
      end
    end
  end
end
