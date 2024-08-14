# frozen_string_literal: true

module SolidusAdmin
  class RolesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    search_scope(:all)
    search_scope(:admin) { _1.where(name: "admin") }

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('roles/index').new(page: @page) }
      end
    end

    def new
      @role = Spree::Role.new

      set_index_page

      respond_to do |format|
        format.html { render component('roles/new').new(page: @page, role: @role) }
      end
    end

    def create
      @role = Spree::Role.new(role_params)

      if @role.save
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.roles_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('roles/new').new(page: @page, role: @role)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @roles = Spree::Role.where(id: params[:id])

      Spree::Role.transaction { @roles.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to solidus_admin.roles_path, status: :see_other
    end

    private

    def set_index_page
      roles = apply_search_to(
        Spree::Role.unscoped.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(roles)
    end

    def role_params
      params.require(:role).permit(:role_id, :name, :description, :type)
    end
  end
end
