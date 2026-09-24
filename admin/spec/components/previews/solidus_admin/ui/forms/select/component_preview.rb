# frozen_string_literal: true

# @component "ui/forms/select"
class SolidusAdmin::UI::Forms::Select::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param multiple toggle
  # @param latency toggle "Simulate request with latency (2000ms)"
  # @param selected_values toggle "Simulated with preselected, known options before the remote request"
  # @param loading_message text
  # @param loading_more_message text
  # @param no_results_message text
  def remote_with_pagination(
    multiple: false,
    latency: false,
    selected_values: true,
    loading_message: nil,
    loading_more_message: nil,
    no_results_message: nil
  )
    args = {label: "Search", name: "select", multiple:, choices: [], placeholder: "Type to search"}

    # FIXME: Currently, preselecting values with our select component is
    # incompatible with our Tom Select selector. We must update
    # `solidus_select.js` to respond to given preselected values.
    if selected_values
      args[:value] = Spree::Product.available.first(multiple ? 2 : 1).map(&:id)
    end

    host = "http://localhost:3000"
    host = host.gsub("http://", "https://app.requestly.io/delay/2000/") if latency
    src =
      Spree::Core::Engine.routes.url_helpers.api_products_url(
        host:,
        params: {token: Spree.user_class.admin.first.spree_api_key}
      )

    args.merge!(
      src:,
      "data-option-value-field": "id",
      "data-option-label-field": "slug",
      "data-query-param": "q",
      "data-no-preload": !selected_values,
      "data-loading-message": loading_message,
      "data-loading-more-message": loading_more_message,
      "data-no-results-message": no_results_message
    )

    render component("ui/forms/select").new(**args)
  end

  # @param size select { choices: [s, m, l] }
  # @param options number
  # @param multiple toggle
  # @param selected toggle
  # @param disabled toggle
  # @param error toggle
  # @param include_blank toggle
  # @param blank_option text
  # @param placeholder text
  # @param hint text
  # @param tip text
  def playground(size: "m", options: 3, multiple: false, selected: false, disabled: false, error: false, include_blank: false, blank_option: nil, placeholder: nil, hint: nil, tip: nil)
    options = (1..options).map { |i| ["Option #{i}", i] }
    if include_blank && blank_option.present?
      include_blank = blank_option
    end

    render component("ui/forms/select").new(
      label: "Label",
      name: "select",
      hint:,
      tip:,
      error: error ? "There is an error" : nil,
      size: size.to_sym,
      choices: options,
      value: (multiple && [1, 2] || 1 if selected),
      multiple:,
      disabled:,
      placeholder:,
      include_blank:
    )
  end
end
