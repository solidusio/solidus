# frozen_string_literal: true

module SolidusAdmin::ProductSpecifications
  extend ActiveSupport::Concern

  included do
    before_action :load_product
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def form_component
    component("products/show/specifications/form").new(product: @product, rule: @rule)
  end

  def respond_with_form
    respond_to do |format|
      format.html { render form_component }
    end
  end

  def respond_with_success(message)
    flash[:notice] = message

    respond_to do |format|
      format.html { redirect_to solidus_admin.product_path(@product), status: :see_other }
      format.turbo_stream { render "solidus_admin/products/specifications_panel" }
    end
  end

  def respond_with_errors
    respond_to do |format|
      format.html { render form_component, status: :unprocessable_entity }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:specifications_modal, form_component),
          status: :unprocessable_entity
      end
    end
  end
end
