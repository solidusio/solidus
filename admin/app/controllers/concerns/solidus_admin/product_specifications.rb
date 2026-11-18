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

  # Numbers the rows of the +association+ nested attributes in the order
  # they were submitted, which is their order in the dialog, skipping the
  # rows marked for destruction.
  def with_row_positions(permitted, association)
    key = :"#{association}_attributes"
    return permitted unless permitted[key]

    position = 0
    rows = permitted[key].transform_values do |row|
      next row if ActiveModel::Type::Boolean.new.cast(row[:_destroy])

      row.merge(position: position += 1)
    end

    permitted.merge(key => rows)
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
