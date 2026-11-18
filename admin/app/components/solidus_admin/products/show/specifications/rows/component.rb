# frozen_string_literal: true

class SolidusAdmin::Products::Show::Specifications::Rows::Component < SolidusAdmin::BaseComponent
  # @param form [SolidusAdmin::FormBuilder] the form the rows belong to
  # @param association [Symbol] the nested attributes association the rows are
  #   bound to, e.g. +:product_properties+
  # @param new_row_href [String] the path that appends a blank row to the list
  def initialize(form:, association:, new_row_href:)
    @form = form
    @association = association
    @new_row_href = new_row_href
  end

  private

  def property_options
    Spree::Property.sorted.pluck(:presentation, :name)
  end
end
