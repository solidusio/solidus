# frozen_string_literal: true

class Spree::Admin::ResourceController < Spree::Admin::BaseController
  include Spree::Backend::Callbacks

  helper_method :new_object_url, :edit_object_url, :object_url, :collection_url
  before_action :load_resource, except: :update_positions
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :resource_invalid

  respond_to :html

  def new
    invoke_callbacks(:new_action, :before)
    respond_with(@object) do |format|
      format.html { render layout: !request.xhr? }
      if request.xhr?
        format.js   { render layout: false }
      end
    end
  end

  def edit
    respond_with(@object) do |format|
      format.html { render layout: !request.xhr? }
      if request.xhr?
        format.js   { render layout: false }
      end
    end
  end

  def update
    invoke_callbacks(:update, :before)
    if @object.update(permitted_resource_params)
      invoke_callbacks(:update, :after)
      respond_with(@object) do |format|
        format.html do
          flash[:success] = flash_message_for(@object, :successfully_updated)
          redirect_to location_after_save
        end
        format.js { render layout: false }
      end
    else
      invoke_callbacks(:update, :fails)
      respond_with(@object) do |format|
        format.html do
          flash.now[:error] = @object.errors.full_messages.join(", ")
          render_after_update_error
        end
        format.js { render layout: false }
      end
    end
  end

  def create
    invoke_callbacks(:create, :before)
    @object.attributes = permitted_resource_params
    if @object.save
      invoke_callbacks(:create, :after)
      flash[:success] = flash_message_for(@object, :successfully_created)
      respond_with(@object) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render layout: false }
      end
    else
      invoke_callbacks(:create, :fails)
      respond_with(@object) do |format|
        format.html do
          flash.now[:error] = @object.errors.full_messages.join(", ")
          render_after_create_error
        end
        format.js { render layout: false }
      end
    end
  end

  def update_positions
    ActiveRecord::Base.transaction do
      params[:positions].each do |id, index|
        model_class.find_by(id: id)&.set_list_position(index)
      end
    end

    respond_to do |format|
      format.js { head :no_content }
    end
  end

  def destroy
    invoke_callbacks(:destroy, :before)

    destroy_result =
      if @object.respond_to?(:discard)
        @object.discard
      elsif @object.respond_to?(:paranoia_destroy)
        @object.paranoia_destroy
      else
        @object.destroy
      end

    if destroy_result
      invoke_callbacks(:destroy, :after)
      flash[:success] = flash_message_for(@object, :successfully_removed)
      respond_with(@object) do |format|
        format.html { redirect_to location_after_destroy }
        format.js   { render partial: "spree/admin/shared/destroy" }
      end
    else
      invoke_callbacks(:destroy, :fails)
      respond_with(@object) do |format|
        message = @object.errors.full_messages.to_sentence
        format.html do
          flash[:error] = message
          redirect_to location_after_destroy
        end
        format.js do
          render status: :unprocessable_entity, plain: message
        end
      end
    end
  end

  private

  class << self
    attr_accessor :parent_data

    def belongs_to(model_name, options = {})
      @parent_data ||= {}
      @parent_data[:model_name] = model_name
      @parent_data[:model_class] = (options[:model_class] || model_name.to_s.classify.constantize)
      @parent_data[:find_by] = options[:find_by] || :id
      @parent_data[:includes] = options[:includes]
    end
  end

  def resource_not_found
    flash[:error] = flash_message_for(model_class.new, :not_found)
    redirect_to collection_url
  end

  def model_class
    "Spree::#{controller_name.classify}".constantize
  end

  def parent_model_name
    self.class.parent_data[:model_name].gsub('spree/', '')
  end

  def model_name
    Spree::Deprecation.warn('model_name is deprecated. Please use parent_model_name instead.', caller)
    parent_model_name
  end

  def object_name
    controller_name.singularize
  end

  def load_resource
    if member_action?
      @object ||= load_resource_instance

      # call authorize! a third time (called twice already in Admin::BaseController)
      # this time we pass the actual instance so fine-grained abilities can control
      # access to individual records, not just entire models.
      authorize! action, @object

      instance_variable_set("@#{object_name}", @object)
    else
      @collection ||= collection

      # note: we don't call authorize here as the collection method should use
      # CanCan's accessible_by method to restrict the actual records returned

      instance_variable_set("@#{controller_name}", @collection)
    end
  end

  def load_resource_instance
    if new_actions.include?(action)
      build_resource
    elsif params[:id]
      find_resource
    end
  end

  def parent_data
    Spree::Deprecation.warn('parent_data is deprecated without replacement.', caller)
    self.class.parent_data
  end

  def parent
    if parent?
      @parent ||= self.class.parent_data[:model_class]
                    .includes(self.class.parent_data[:includes])
                    .find_by(self.class.parent_data[:find_by] => params["#{parent_model_name}_id"])
      instance_variable_set("@#{parent_model_name}", @parent)
    else
      Spree::Deprecation.warn "Calling #parent is deprecated on a ResourceController which has not defined a belongs_to"
      nil
    end
  end

  def parent?
    self.class.parent_data.present?
  end

  def find_resource
    if parent?
      parent.send(controller_name).find(params[:id])
    else
      model_class.find(params[:id])
    end
  end

  def build_resource
    if parent?
      parent.send(controller_name).build
    else
      model_class.new
    end
  end

  def collection
    return parent.send(controller_name) if parent?
    if model_class.respond_to?(:accessible_by) && !current_ability.has_block?(params[:action], model_class)
      model_class.accessible_by(current_ability, action)
    else
      model_class.all
    end
  end

  def location_after_destroy
    collection_url
  end

  def location_after_save
    collection_url
  end

  # URL helpers

  def new_object_url(options = {})
    if parent?
      spree.new_polymorphic_url([:admin, parent, model_class], options)
    else
      spree.new_polymorphic_url([:admin, model_class], options)
    end
  end

  def edit_object_url(object, options = {})
    if parent?
      spree.polymorphic_url([:edit, :admin, parent, object], options)
    else
      spree.polymorphic_url([:edit, :admin, object], options)
    end
  end

  def object_url(object = nil, options = {})
    target = object ? object : @object

    if parent?
      spree.polymorphic_url([:admin, parent, target], options)
    else
      spree.polymorphic_url([:admin, target], options)
    end
  end

  def collection_url(options = {})
    if parent?
      spree.polymorphic_url([:admin, parent, model_class], options)
    else
      spree.polymorphic_url([:admin, model_class], options)
    end
  end

  # Allow all attributes to be updatable.
  #
  # Other controllers can, should, override it to set custom logic
  def permitted_resource_params
    params[object_name].present? ? params.require(object_name).permit! : ActionController::Parameters.new.permit!
  end

  def collection_actions
    [:index]
  end

  def member_action?
    !collection_actions.include? action
  end

  def new_actions
    [:new, :create]
  end

  def render_after_create_error
    render action: 'new'
  end

  def render_after_update_error
    render action: 'edit'
  end

  def resource_invalid(exception)
    invoke_callbacks(action, :fails)
    respond_with(@object) do |format|
      format.html do
        flash.now[:error] = exception.message
        if @object.new_record?
          render_after_create_error
        else
          render_after_update_error
        end
      end
      format.js { render layout: false }
    end
  end
end
