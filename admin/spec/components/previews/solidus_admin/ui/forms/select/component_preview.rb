# frozen_string_literal: true

# @component "ui/forms/select"
class SolidusAdmin::UI::Forms::Select::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param multiple toggle
  # @param latency toggle "Simulate request latency (2000ms)"
  # @param loading_message text
  # @param loading_more_message text
  # @param no_results_message text
  def remote_with_pagination(multiple: false, latency: false, loading_message: nil, loading_more_message: nil, no_results_message: nil)
    args = { label: "Search", name: "select", multiple:, choices: [], placeholder: "Type to search" }
    delay_url = "app.requestly.io/delay/2000/" if latency
    src = "https://#{delay_url}api.github.com/search/repositories"
    args.merge!(
      src:,
      "data-option-value-field": "id",
      "data-option-label-field": "full_name",
      "data-json-path": "items",
      "data-query-param": "q",
      "data-no-preload": "true",
      "data-loading-message": loading_message,
      "data-loading-more-message": loading_more_message,
      "data-no-results-message": no_results_message,
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
  # @param placeholder text
  # @param hint text
  # @param tip text
  def playground(size: "m", options: 3, multiple: false, selected: false, disabled: false, error: false, include_blank: true, placeholder: nil, hint: nil, tip: nil)
    options = (1..options).map { |i| ["Option #{i}", i] }
    options.unshift(["None", ""]) if include_blank

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
      placeholder:
    )
  end
end
