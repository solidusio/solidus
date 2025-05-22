# frozen_string_literal: true

module SolidusAdmin
  class ResourcesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    helper_method :search_filter_params

    before_action :set_paginated_resources, only: %i[index]
    before_action :set_resource, only: %i[edit update]

    # GET /index
    #
    # Uses {set_paginated_resources} to set @resources
    # and a instance variable with the plural name of the resource.
    #
    # Uses the geared_pagination gem to set @page for pagination.
    #
    # @see set_paginated_resources
    # @see resources_collection
    def index
      respond_to do |format|
        format.html { render index_component.new(page: @page) }
        format.json { render json: blueprint.render(@page.records, view: blueprint_view) }
      end
    end

    def new
      @resource ||= resource_class.new
      render new_component.new(@resource)
    end

    def create
      @resource ||= resource_class.new(permitted_resource_params)

      if @resource.save
        flash[:notice] = t('.success')
        redirect_to after_create_path, status: :see_other
      else
        page_component = new_component.new(@resource)
        render_resource_form_with_errors(page_component)
      end
    end

    def edit
      respond_to do |format|
        format.html { render edit_component.new(@resource) }
      end
    end

    def update
      if @resource.update(permitted_resource_params)
        flash[:notice] = t('.success')
        redirect_to after_update_path, status: :see_other
      else
        page_component = edit_component.new(@resource)
        render_resource_form_with_errors(page_component)
      end
    end

    def destroy
      @resource = resource_class.where(id: params[:id])

      resource_class.transaction { @resource.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to after_destroy_path, status: :see_other
    end

    private

    def search_filter_params
      request.params.slice(:q, :page)
    end

    def set_paginated_resources
      @resources ||= apply_search_to(
        resources_collection,
          param: :q,
        ).tap do |resources|
          instance_variable_set("@#{plural_resource_name}", resources)
          # sets @page instance variable in geared_pagination gem
          set_page_and_extract_portion_from(resources, ordered_by: resources_sorting_options, per_page:)
        end
    end

    def resources_sorting_options
      { id: :desc }
    end

    def resources_collection
      resource_class.all
    end

    def per_page; end

    def set_resource
      @resource ||= resource_class.find(params[:id]).tap do |resource|
          instance_variable_set("@#{resource_name}", resource)
      end
    end

    def resource_class
      raise NotImplementedError,
        "You must implement the resource_class method in #{self.class}"
    end

    def resource_name
      resource_class.model_name.singular_route_key
    end

    def plural_resource_name
      resource_class.model_name.route_key
    end

    def index_component
      component("#{plural_resource_name}/index")
    end

    def new_component
      component("#{plural_resource_name}/new")
    end

    def edit_component
      component("#{plural_resource_name}/edit")
    end

    def render_resource_form_with_errors(page_component)
      respond_to do |format|
        format.html do
          render page_component, status: :unprocessable_entity
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(resource_form_frame, page_component),
            status: :unprocessable_entity
        end
      end
    end

    def permitted_resource_params
      raise NotImplementedError,
        "You must implement the permitted_resource_params method in #{self.class}"
    end

    def after_create_path
      solidus_admin.send("#{plural_resource_name}_path", **search_filter_params)
    end

    def after_update_path
      solidus_admin.send("#{plural_resource_name}_path", **search_filter_params)
    end

    def after_destroy_path
      solidus_admin.send("#{plural_resource_name}_path", **search_filter_params)
    end

    def resource_form_frame
      :resource_form
    end
  end
end
