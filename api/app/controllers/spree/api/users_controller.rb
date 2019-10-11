# frozen_string_literal: true

class Solidus::Api::UsersController < Solidus::Api::ResourceController
  private

  attr_reader :user

  def model_class
    Solidus.user_class
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
