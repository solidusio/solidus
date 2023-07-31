# frozen_string_literal: true

module SolidusAdmin
  class AccountsController < SolidusAdmin::BaseController
    def show
      redirect_to spree.edit_admin_user_path(current_solidus_admin_user)
    end
  end
end
