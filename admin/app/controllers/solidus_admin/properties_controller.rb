# frozen_string_literal: true

module SolidusAdmin
  class PropertiesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    before_action :find_property, only: %i[edit update]

    def index
      set_index_page

      properties = apply_search_to(
        Spree::Property.order(created_at: :desc, id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(
        properties,
      )

      respond_to do |format|
        format.html { render component('properties/index').new(page: @page) }
      end
    end

    def new
      @property = Spree::Property.new

      set_index_page

      respond_to do |format|
        format.html { render component('properties/new').new(page: @page, property: @property) }
      end
    end

    def create
      @property = Spree::Property.new(property_params)

      if @property.save
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.properties_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('properties/new').new(page: @page, property: @property)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def edit
      set_index_page

      respond_to do |format|
        format.html { render component('properties/edit').new(page: @page, property: @property) }
      end
    end

    def update
      if @property.update(property_params)
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.properties_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('properties/edit').new(page: @page, property: @property)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @properties = Spree::Property.where(id: params[:id])

      Spree::Property.transaction do
        @properties.destroy_all
      end

      flash[:notice] = t('.success')
      redirect_to properties_path, status: :see_other
    end

    private

    def find_property
      @property = Spree::Property.find(params[:id])
    end

    def property_params
      params.require(:property).permit(:name, :presentation)
    end

    def set_index_page
      properties = apply_search_to(
        Spree::Property.unscoped.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(properties)
    end
  end
end
