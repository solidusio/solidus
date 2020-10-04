# frozen_string_literal: true

module Spree
  module Admin
    module Users
      class ApiKeyController < Spree::Admin::BaseController
        def create
          if user.generate_spree_api_key!
            flash[:success] = t('spree.admin.api.key_generated')
          end
          redirect_to edit_admin_user_path(user)
        end

        def destroy
          if user.clear_spree_api_key!
            flash[:success] = t('spree.admin.api.key_cleared')
          end
          redirect_to edit_admin_user_path(user)
        end

        private

        def user
          @user ||= Spree.user_class.find(params[:user_id])
        end
      end
    end
  end
end
