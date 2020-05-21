# frozen_string_literal: true

module Spree
  module Admin
    module Users
      class ApiKeyController < Spree::Admin::BaseController
        def create
          Spree::Deprecation.warn <<-WARN.strip_heredoc, caller
            The route or controller action you are using is deprecated.

            Instead of:
            admin_user_api_key        POST   /admin/users/:user_id/api_key

            Please use:
            api_user_api_key          POST   /api/users/:user_id/api_key
          WARN
          if user.generate_spree_api_key!
            flash[:success] = t('spree.admin.api.key_generated')
          end
          redirect_to edit_admin_user_path(user)
        end

        def destroy
          Spree::Deprecation.warn <<-WARN.strip_heredoc, caller
            The route or controller action you are using is deprecated.

            Instead of:
            admin_user_api_key     DELETE /admin/users/:user_id/api_key

            Please use:
            api_user_api_key       DELETE /api/users/:user_id/api_key
          WARN
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
