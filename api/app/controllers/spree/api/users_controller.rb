# frozen_string_literal: true

class Spree::Api::UsersController < Spree::Api::BaseController
  before_action :load_resource, only: [:show, :update, :destroy]

  def index
    user_scope = user_class.accessible_by(current_ability, :show)
    if params[:ids]
      ids = params[:ids].split(",").flatten
      @users = user_scope.where(id: ids)
    else
      @users = user_scope.ransack(params[:q]).result
    end

    @users = paginate(@users.distinct)
    respond_with(@users)
  end

  def show
    respond_with(@user)
  end

  def new
    authorize! :new, user_class
    respond_with(user_class.new)
  end

  def create
    authorize! :create, user_class

    @user = user_class.new(permitted_user_params)

    if @user.save
      respond_with(@user, status: 201, default_template: :show)
    else
      invalid_resource!(@user)
    end
  end

  def update
    authorize! :update, @user

    if @user.update(permitted_user_params)
      respond_with(@user, status: 200, default_template: :show)
    else
      invalid_resource!(@user)
    end
  end

  def destroy
    authorize! :destroy, @user

    destroy_result = if @user.respond_to?(:discard)
      @user.discard
    else
      @user.destroy
    end

    if destroy_result
      respond_with(@user, status: 204)
    else
      invalid_resource!(@user)
    end
  rescue ActiveRecord::DeleteRestrictionError
    render "spree/api/errors/delete_restriction", status: 422
  end

  private

  def user_class
    Spree.user_class
  end

  def load_resource
    @user = user_class.accessible_by(current_ability, :show).find(params[:id])
  end

  def permitted_user_params
    params.require(:user).permit(permitted_user_attributes)
  end

  def permitted_user_attributes
    if action_name == "create" || can?(:update_email, @user)
      super | [:email]
    else
      super
    end
  end
end

