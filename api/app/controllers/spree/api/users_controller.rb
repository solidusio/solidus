# frozen_string_literal: true

class Spree::Api::UsersController < Spree::Api::ResourceController
  def index
    user_scope = model_class.accessible_by(current_ability, :show)
    if params[:ids]
      ids = params[:ids].split(",").flatten
      @users = user_scope.where(id: ids)
    else
      @users = user_scope.ransack(params[:q]).result
    end

    @users = paginate(@users.distinct)
    respond_with(@users)
  end

  private

  attr_reader :user

  def model_class
    Spree.user_class
  end

  def user_params
    permitted_resource_params
  end

  def permitted_resource_attributes
    if action_name == "create" || can?(:update_email, user)
      super | [:email]
    else
      super
    end
  end
end
