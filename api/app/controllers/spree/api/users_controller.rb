class Spree::Api::UsersController < Spree::Api::ResourceController

  private

  def user
    @user
  end

  def model_class
    Spree.user_class
  end

  def user_params
    permitted_resource_params
  end

  def permitted_resource_attributes
    super | [bill_address_attributes: permitted_address_attributes, ship_address_attributes: permitted_address_attributes]
  end
end
