# frozen_string_literal: true

module SolidusAdmin
  class UsersController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    search_scope(:customers, default: true) { _1.left_outer_joins(:role_users).where(role_users: { id: nil }) }
    search_scope(:admin) { _1.joins(:role_users).distinct }
    search_scope(:with_orders) { _1.joins(:orders).distinct }
    search_scope(:without_orders) { _1.left_outer_joins(:orders).where(orders: { id: nil }) }
    search_scope(:all)

    def index
      users = apply_search_to(
        Spree.user_class.order(created_at: :desc, id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(users)

      respond_to do |format|
        format.html { render component('users/index').new(page: @page) }
      end
    end

    def destroy
      @users = Spree.user_class.where(id: params[:id])

      Spree.user_class.transaction { @users.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to users_path, status: :see_other
    end

    private

    def load_user
      @user = Spree.user_class.find_by!(number: params[:id])
      authorize! action_name, @user
    end

    def user_params
      params.require(:user).permit(:user_id, permitted_user_attributes)
    end

    def authorization_subject
      Spree.user_class
    end
  end
end
