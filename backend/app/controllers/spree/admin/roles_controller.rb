# frozen_string_literal: true

module Spree
  module Admin
    class RolesController < ResourceController
     

    before_action :load_role, only: [:edit, :update, :destroy]

    def index
      @roles = Spree::Role.all
    end

    def new
      @role = Spree::Role.new
    end

    def create
      @role = Spree::Role.new(role_params)
      if @role.save
        redirect_to admin_roles_path, notice: 'Role created successfully'
      else
        render :new
      end
    end

    def edit
      # The 'load_role' before_action loads the role to be edited
    end

    def update
      if @role.update(role_params)
        redirect_to admin_roles_path, notice: 'Role updated successfully'
      else
        render :edit
      end
    end

    private

    def role_params
      params.require(:role).permit(:name)
    end

    def load_role
      @role = Spree::Role.find(params[:id])
    end

    end
  end
end
