# frozen_string_literal: true

module SolidusAdmin
  class UsersController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search
    include Spree::Core::ControllerHelpers::StrongParameters

    before_action :set_user, only: [:edit, :addresses, :update_addresses, :orders, :items]

    search_scope(:all, default: true)
    search_scope(:customers) { _1.left_outer_joins(:role_users).where(role_users: { id: nil }) }
    search_scope(:admin) { _1.joins(:role_users).distinct }
    search_scope(:with_orders) { _1.joins(:orders).distinct }
    search_scope(:without_orders) { _1.left_outer_joins(:orders).where(orders: { id: nil }) }

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

    def addresses
      respond_to do |format|
        format.turbo_stream { render turbo_stream: '<turbo-stream action="refresh" />' }
        format.html { render component('users/addresses').new(user: @user) }
      end
    end

    def update_addresses
      set_address_from_params

      if @address.valid? && @user.update(user_params)
        flash[:success] = t(".#{@type}.success")

        respond_to do |format|
          format.turbo_stream { render turbo_stream: '<turbo-stream action="refresh" />' }
          format.html { render component('users/addresses').new(user: @user) }
        end
      else
        respond_to do |format|
          format.html { render component('users/addresses').new(user: @user, address: @address, type: @type), status: :unprocessable_entity }
        end
      end
    end

    def orders
      set_orders

      respond_to do |format|
        format.html { render component('users/orders').new(user: @user, orders: @orders) }
      end
    end

    def items
      set_items

      respond_to do |format|
        format.html { render component('users/items').new(user: @user, items: @items) }
      end
    end

    def edit
      respond_to do |format|
        format.html { render component('users/edit').new(user: @user) }
      end
    end

    def destroy
      @users = Spree.user_class.where(id: params[:id])

      Spree.user_class.transaction { @users.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to users_path, status: :see_other
    end

    private

    def set_user
      @user = Spree.user_class.find(params[:id])
    end

    def user_params
      params.require(:user).permit(
        :user_id,
        permitted_user_attributes,
        bill_address_attributes: permitted_address_attributes,
        ship_address_attributes: permitted_address_attributes
      )
    end

    # @note This method is used to generate validation errors on the address.
    #   Since the update is being performed via the @user, and not directly on
    #   the @address, we sadly don't seem to get these errors automatically.
    def set_address_from_params
      if user_params.key?(:bill_address_attributes)
        @address = Spree::Address.new(user_params[:bill_address_attributes])
        @type = "bill"
      elsif user_params.key?(:ship_address_attributes)
        @address = Spree::Address.new(user_params[:ship_address_attributes])
        @type = "ship"
      end
    end

    def set_orders
      params[:q] ||= {}
      @search = Spree::Order.reverse_chronological.ransack(params[:q].merge(user_id_eq: @user.id))
      @orders = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
    end

    def set_items
      params[:q] ||= {}
      @search = Spree::Order.reverse_chronological.includes(line_items: { variant: [:product, { option_values: :option_type }] }).ransack(params[:q].merge(user_id_eq: @user.id))
      @orders = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
      @items = @orders&.map(&:line_items)&.flatten
    end

    def authorization_subject
      Spree.user_class
    end
  end
end
