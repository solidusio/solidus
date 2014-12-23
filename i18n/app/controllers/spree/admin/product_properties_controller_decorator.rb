Spree::Admin::ProductPropertiesController.class_eval do
  def translate
    product_property = Spree::ProductProperty.find(params[:id])
    product_property.update update_product_property_attribute
    redirect_to spree.admin_product_product_properties_path(product_property.product)
  end

  private
  def update_product_property_attribute
    params.require(:product_property).permit(permitted_params)
  end

  def permitted_params
   [translations_attributes: [:id, :locale, :value]]
  end
end
