module Spree
  module Admin
    class UsersController < ResourceController
      rescue_from Solidus::Core::DestroyWithOrdersError, with: :user_destroy_with_orders_error

      after_action :sign_in_if_change_own_password, only: :update

      # http://soliduscommerce.com/blog/2010/11/02/json-hijacking-vulnerability/
      before_action :check_json_authenticity, only: :index
      before_filter :load_roles, :load_stock_locations, only: [:edit, :new]

      def index
        respond_with(@collection) do |format|
          format.html
          format.json { render :json => json_data }
        end
      end

      def show
        redirect_to edit_admin_user_path(@user)
      end

      def create
        @user = Solidus.user_class.new(user_params)
        if @user.save
          set_roles
          set_stock_locations

          flash[:success] = Solidus.t(:created_successfully)
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
          flash[:success] = Solidus.t(:account_updated)
        end

        redirect_to edit_admin_user_url(@user)
      end

      def addresses
        if request.put?
          if @user.update_attributes(user_params)
            flash.now[:success] = Solidus.t(:account_updated)
          end

          render :addresses
        end
      end

      def orders
        params[:q] ||= {}
        @search = Solidus::Order.reverse_chronological.ransack(params[:q].merge(user_id_eq: @user.id))
        @orders = @search.result.page(params[:page]).per(Solidus::Config[:admin_products_per_page])
      end

      def items
        params[:q] ||= {}
        @search = Solidus::Order.includes(
          line_items: {
            variant: [:product, { option_values: :option_type }]
          }).ransack(params[:q].merge(user_id_eq: @user.id))
        @orders = @search.result.page(params[:page]).per(Solidus::Config[:admin_products_per_page])
      end

      def generate_api_key
        if @user.generate_solidus_api_key!
          flash[:success] = Solidus.t('api.key_generated')
        end
        redirect_to edit_admin_user_path(@user)
      end

      def clear_api_key
        if @user.clear_solidus_api_key!
          flash[:success] = Solidus.t('api.key_cleared')
        end
        redirect_to edit_admin_user_path(@user)
      end

      def model_class
        Solidus.user_class
      end

      private

        def collection
          return @collection if @collection.present?
          if request.xhr? && params[:q].present?
            @collection = Solidus.user_class.includes(:bill_address, :ship_address)
                              .where("solidus_users.email #{LIKE} :search
                                     OR (solidus_addresses.firstname #{LIKE} :search AND solidus_addresses.id = solidus_users.bill_address_id)
                                     OR (solidus_addresses.lastname  #{LIKE} :search AND solidus_addresses.id = solidus_users.bill_address_id)
                                     OR (solidus_addresses.firstname #{LIKE} :search AND solidus_addresses.id = solidus_users.ship_address_id)
                                     OR (solidus_addresses.lastname  #{LIKE} :search AND solidus_addresses.id = solidus_users.ship_address_id)",
                                    { :search => "#{params[:q].strip}%" })
                              .limit(params[:limit] || 100)
          else
            @search = Solidus.user_class.ransack(params[:q])
            @collection = @search.result.page(params[:page]).per(Solidus::Config[:admin_products_per_page])
          end
        end

        def user_params
          attributes = permitted_user_attributes

          if action_name == "create" || can?(:update_email, @user)
            attributes |= [:email]
          end

          if can? :manage, Solidus::Role
            attributes += [{ solidus_role_ids: [] }]
          end

          params.require(:user).permit(attributes)
        end

        # handling raise from Solidus::Admin::ResourceController#destroy
        def user_destroy_with_orders_error
          invoke_callbacks(:destroy, :fails)
          render :status => :forbidden, :text => Solidus.t(:error_user_destroy_with_orders)
        end

        # Allow different formats of json data to suit different ajax calls
        def json_data
          json_format = params[:json_format] or 'default'
          case json_format
          when 'basic'
            collection.map { |u| { 'id' => u.id, 'name' => u.email } }.to_json
          else
            address_fields = [:firstname, :lastname, :address1, :address2, :city, :zipcode, :phone, :state_name, :state_id, :country_id, :country_iso]
            includes = { :only => address_fields , :include => { :state => { :only => :name }, :country => { :only => :name } } }

            collection.to_json(:only => [:id, :email], :include =>
                               { :bill_address => includes, :ship_address => includes })
          end
        end

        def sign_in_if_change_own_password
          if try_solidus_current_user == @user && @user.password.present?
            sign_in(@user, :event => :authentication, :bypass => true)
          end
        end

        def load_roles
          @roles = Solidus::Role.all
          @user_roles = @user.solidus_roles
        end

        def load_stock_locations
          @stock_locations = Solidus::StockLocation.all
        end

        def set_roles
          # FIXME: user_params permits the roles that can be set, if solidus_role_ids is set.
          # when submitting a user with no roles, the param is not present. Because users can be updated
          # with some users being able to set roles, and some users not being able to set roles, we have to check
          # if the roles should be cleared, or unchanged again here. The roles form should probably hit a seperate
          # action or controller to remedy this.
          if user_params[:solidus_role_ids]
            @user.solidus_roles = Solidus::Role.where(id: user_params[:solidus_role_ids])
          elsif can?(:manage, Solidus::Role)
            @user.solidus_roles = []
          end
        end

        def set_stock_locations
          @user.stock_locations = Solidus::StockLocation.where(id: (params[:user][:stock_location_ids] || []))
        end
    end
  end
end
