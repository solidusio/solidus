# frozen_string_literal: true

class Spree::Api::ResourceController < Spree::Api::BaseController
  before_action :load_resource, only: [:show, :update, :destroy]

  def index
    collection_scope = model_class.accessible_by(current_ability, :read)
    if params[:ids]
      ids = params[:ids].split(",").flatten
      collection_scope = collection_scope.where(id: ids)
    else
      collection_scope = collection_scope.ransack(params[:q]).result
    end

    @collection = paginate(collection_scope)
    instance_variable_set("@#{controller_name}", @collection)

    respond_with(@collection)
  end

  def show
    respond_with(@object)
  end

  def new
    authorize! :new, model_class
    respond_with(model_class.new)
  end

  def create
    authorize! :create, model_class

    @object = model_class.new(permitted_resource_params)
    instance_variable_set("@#{object_name}", @object)

    if @object.save
      respond_with(@object, status: 201, default_template: :show)
    else
      invalid_resource!(@object)
    end
  end

  def update
    authorize! :update, @object

    if @object.update(permitted_resource_params)
      respond_with(@object, status: 200, default_template: :show)
    else
      invalid_resource!(@object)
    end
  end

  def destroy
    authorize! :destroy, @object

    if @object.destroy
      respond_with(@object, status: 204)
    else
      invalid_resource!(@object)
    end
  rescue ActiveRecord::DeleteRestrictionError
    render "spree/api/errors/delete_restriction", status: 422
  end

  protected

  def load_resource
    @object = model_class.accessible_by(current_ability, :read).find(params[:id])
    instance_variable_set("@#{object_name}", @object)
  end

  def permitted_resource_params
    params.require(object_name).permit(permitted_resource_attributes)
  end

  def permitted_resource_attributes
    send("permitted_#{object_name}_attributes")
  end

  def model_class
    "Spree::#{controller_name.classify}".constantize
  end

  def object_name
    controller_name.singularize
  end
end
