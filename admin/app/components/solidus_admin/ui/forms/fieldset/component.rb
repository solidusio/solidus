# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Fieldset::Component < SolidusAdmin::BaseComponent
  # @param legend [String, nil] The legend of the fieldset.
  # @param fieldset_attributes [Hash] Attributes to pass to the fieldset tag.
  # @param legend_attributes [Hash, nil] Attributes to pass to the legend tag.
  # @param toggletip_attributes [Hash, nil] Attributes to pass to a toggletip
  #   component that will be rendered after the legend.
  def initialize(
    legend: nil,
    attributes: {},
    legend_attributes: {},
    toggletip_attributes: {}
  )
    @legend = legend
    @attributes = attributes
    @legend_attributes = legend_attributes
    @toggletip_attributes = toggletip_attributes
  end

  def fieldset_html_attributes
    {
      class: fieldset_classes,
      **@attributes.except(:class)
    }
  end

  def fieldset_classes
    %w[p-6 mb-6 border border-gray-100 rounded-lg] + Array(@attributes[:class]).compact
  end

  def legend_and_toggletip_tags
    return "" unless @legend || @toggletip_attributes.any?

    tag.div(class: "flex mb-4") do
      legend_tag + toggletip_tag
    end
  end

  def legend_tag
    return "".html_safe unless @legend

    tag.legend(@legend, **legend_html_attributes)
  end

  def legend_html_attributes
    {
      class: legend_classes,
      **@legend_attributes.except(:class)
    }
  end

  def legend_classes
    %w[body-title mr-2] + Array(@legend_attributes[:class]).compact
  end

  def toggletip_tag
    return "" unless @toggletip_attributes.any?

    tag.div do
      render component("ui/toggletip").new(**@toggletip_attributes)
    end
  end
end
