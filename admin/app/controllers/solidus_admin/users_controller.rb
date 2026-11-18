# frozen_string_literal: true

module SolidusAdmin
  class UsersController < SolidusAdmin::ResourcesController
    include SolidusAdmin::ControllerHelpers::Search
    include Spree::Core::ControllerHelpers::StrongParameters

    before_action :set_resource, only: [:addresses, :edit, :items, :orders, :update, :update_addresses]

    search_scope(:all, default: true)
    search_scope(:customers) { _1.left_outer_joins(:role_users).where(role_users: {id: nil}) }
    search_scope(:admin) { _1.joins(:role_users).distinct }
    search_scope(:with_orders) { _1.joins(:orders).distinct }
    search_scope(:without_orders) { _1.left_outer_joins(:orders).where(orders: {id: nil}) }

    def addresses
      respond_to do |format|
        format.turbo_stream { render turbo_stream: '<turbo-stream action="refresh" />' }
        format.html { render component("users/addresses").new(user: @resource) }
      end
    end

    def update_addresses
      set_address_from_params

      if @address.valid? && @resource.update(permitted_resource_params)
        flash[:notice] = t(".#{@type}.success")

        respond_to do |format|
          format.turbo_stream { render turbo_stream: '<turbo-stream action="refresh" />' }
          format.html { render component("users/addresses").new(user: @resource) }
        end
      else
        respond_to do |format|
          format.html { render component("users/addresses").new(user: @resource, address: @address, type: @type), status: :unprocessable_entity }
        end
      end
    end

    def orders
      set_orders

      respond_to do |format|
        format.html { render component("users/orders").new(user: @resource, orders: @orders) }
      end
    end

    def items
      set_items

      respond_to do |format|
        format.html { render component("users/items").new(user: @resource, items: @items) }
      end
    end

    def destroy
      @resources = Spree.user_class.where(id: params[:id])

      Spree.user_class.transaction { @resources.destroy_all }

      flash[:notice] = t(".success")
      redirect_back_or_to users_path, status: :see_other
    end

    private

    def after_update_path = solidus_admin.edit_user_path(@resource)

    def authorization_subject = Spree.user_class

    def permitted_resource_params
      params.require(:user).permit(
        :email,
        :user_id,
        *permitted_user_attributes,
        bill_address_attributes: permitted_address_attributes,
        ship_address_attributes: permitted_address_attributes,
        spree_role_ids: []
      )
    end

    def resource_class = Spree.user_class

    def resource_collection = Spree.user_class.all

    def resource_sorting_options = {created_at: :desc, id: :desc}

    def set_user
      @resource = Spree.user_class.find(params[:id])
    end

    # @note This method is used to generate validation errors on the address.
    #   Since the update is being performed via the @resource, and not directly on
    #   the address, we sadly don't seem to get these errors automatically.
    def set_address_from_params
      if permitted_resource_params.key?(:bill_address_attributes)
        @address = Spree::Address.new(
          permitted_resource_params[:bill_address_attributes]
        )
        @type = "bill"
      elsif permitted_resource_params.key?(:ship_address_attributes)
        @address = Spree::Address.new(
          permitted_resource_params[:ship_address_attributes]
        )
        @type = "ship"
      end
    end

    def set_orders
      params[:q] ||= {}
      @search = Spree::Order.reverse_chronological.ransack(params[:q].merge(user_id_eq: @resource.id))
      @orders = @search.result.page(params[:page]).per(Spree::Config.admin_products_per_page)
    end

    def set_items
      params[:q] ||= {}
      @search = Spree::Order.reverse_chronological.includes(line_items: {variant: [:product, {option_values: :option_type}]}).ransack(params[:q].merge(user_id_eq: @resource.id))
      @orders = @search.result.page(params[:page]).per(Spree::Config.admin_products_per_page)
      @items = @orders&.map(&:line_items)&.flatten
    end
  end
end
