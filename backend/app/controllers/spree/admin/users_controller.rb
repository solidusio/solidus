module Spree
  module Admin
    class UsersController < ResourceController
      rescue_from Spree::Core::DestroyWithOrdersError, with: :user_destroy_with_orders_error

      after_action :sign_in_if_change_own_password, only: :update

      before_action :load_roles, :load_stock_locations, only: [:edit, :new]

      def index
        respond_with(@collection) do |format|
          format.html
        end
      end

      def show
        redirect_to edit_admin_user_path(@user)
      end

      def create
        @user = Spree.user_class.new(user_params)
        if @user.save
          set_roles
          set_stock_locations

          flash[:success] = Spree.t(:created_successfully)
          redirect_to edit_admin_user_url(@user)
        else
          load_roles
          load_stock_locations

          render :new, status: :unprocessable_entity
        end
      end

      def update
        if @user.update_attributes(user_params)
          set_roles
          set_stock_locations
          flash[:success] = Spree.t(:account_updated)
          redirect_to edit_admin_user_url(@user)
        else
          load_roles
          load_stock_locations

          render :edit, status: :unprocessable_entity
        end
      end

      def addresses
        if request.put?
          if @user.update_attributes(user_params)
            flash.now[:success] = Spree.t(:account_updated)
          end

          render :addresses
        end
      end

      def orders
        params[:q] ||= {}
        @search = Spree::Order.reverse_chronological.ransack(params[:q].merge(user_id_eq: @user.id))
        @orders = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def items
        params[:q] ||= {}
        @search = Spree::Order.includes(
          line_items: {
            variant: [:product, { option_values: :option_type }]
          }).ransack(params[:q].merge(user_id_eq: @user.id))
        @orders = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      end

      def generate_api_key
        if @user.generate_spree_api_key!
          flash[:success] = Spree.t('api.key_generated')
        end
        redirect_to edit_admin_user_path(@user)
      end

      def clear_api_key
        if @user.clear_spree_api_key!
          flash[:success] = Spree.t('api.key_cleared')
        end
        redirect_to edit_admin_user_path(@user)
      end

      def model_class
        Spree.user_class
      end

      private

      def collection
        return @collection if @collection.present?
        if request.xhr? && params[:q].present?
          @collection = Spree.user_class.includes(:bill_address, :ship_address)
                            .where("spree_users.email #{LIKE} :search
                                   OR (spree_addresses.firstname #{LIKE} :search AND spree_addresses.id = spree_users.bill_address_id)
                                   OR (spree_addresses.lastname  #{LIKE} :search AND spree_addresses.id = spree_users.bill_address_id)
                                   OR (spree_addresses.firstname #{LIKE} :search AND spree_addresses.id = spree_users.ship_address_id)
                                   OR (spree_addresses.lastname  #{LIKE} :search AND spree_addresses.id = spree_users.ship_address_id)",
                                  { search: "#{params[:q].strip}%" })
                            .limit(params[:limit] || 100)
        else
          @search = Spree.user_class.ransack(params[:q])
          @collection = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
        end
      end

      def user_params
        attributes = permitted_user_attributes

        if action_name == "create" || can?(:update_email, @user)
          attributes |= [:email]
        end

        if can? :manage, Spree::Role
          attributes += [{ spree_role_ids: [] }]
        end

        params.require(:user).permit(attributes)
      end

      # handling raise from Spree::Admin::ResourceController#destroy
      def user_destroy_with_orders_error
        invoke_callbacks(:destroy, :fails)
        render status: :forbidden, text: Spree.t(:error_user_destroy_with_orders)
      end

      def sign_in_if_change_own_password
        if try_spree_current_user == @user && @user.password.present?
          sign_in(@user, event: :authentication, bypass: true)
        end
      end

      def load_roles
        @roles = Spree::Role.all
        @user_roles = @user.spree_roles
      end

      def load_stock_locations
        @stock_locations = Spree::StockLocation.all
      end

      def set_roles
        # FIXME: user_params permits the roles that can be set, if spree_role_ids is set.
        # when submitting a user with no roles, the param is not present. Because users can be updated
        # with some users being able to set roles, and some users not being able to set roles, we have to check
        # if the roles should be cleared, or unchanged again here. The roles form should probably hit a seperate
        # action or controller to remedy this.
        if user_params[:spree_role_ids]
          @user.spree_roles = Spree::Role.where(id: user_params[:spree_role_ids])
        elsif can?(:manage, Spree::Role)
          @user.spree_roles = []
        end
      end

      def set_stock_locations
        @user.stock_locations = Spree::StockLocation.where(id: (params[:user][:stock_location_ids] || []))
      end
    end
  end
end
