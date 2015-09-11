class Spree::Api::UsersController < Spree::Api::ResourceController

  protected

  def model_class
    Spree.user_class
  end

  def permitted_resource_attributes
    super | [bill_address_attributes: permitted_address_attributes, ship_address_attributes: permitted_address_attributes]
  end
end
