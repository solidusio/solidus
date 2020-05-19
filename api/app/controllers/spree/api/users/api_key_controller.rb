# frozen_string_literal: true

module Spree
  module Api
    module Users
      class ApiKeyController < Spree::Api::BaseController
        def create
          authorize! :manage, model_class
          user.generate_spree_api_key!
          respond_with(user, default_template: 'spree/api/users/api_key')
        end

        def destroy
          authorize! :manage, model_class
          user.clear_spree_api_key!
          head 204
        end

        private

        def user
          @user ||= model_class.find(params[:user_id])
        end

        def model_class
          Spree.user_class
        end
      end
    end
  end
end
