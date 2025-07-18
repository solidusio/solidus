# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Select::Component < SolidusAdmin::BaseComponent
  FONT_SIZES = {
    s: "[&>.control]:text-xs [&_.dropdown]:text-xs",
    m: "[&>.control]:text-sm [&_.dropdown]:text-sm",
    l: "[&>.control]:text-base [&_.dropdown]:text-base",
  }.freeze

  HEIGHTS = {
    control: {
      s: "[&>.control]:min-h-7",
      m: "[&>.control]:min-h-9",
      l: "[&>.control]:min-h-12",
    },
    option: {
      s: "[&_.option]:h-7",
      m: "[&_.option]:h-9",
      l: "[&_.option]:h-12",
    },
    item: {
      s: "[&_.item]:h-5",
      m: "[&_.item]:h-5.5",
      l: "[&_.item]:h-8",
    },
  }.freeze

  # Render custom select component, which uses "solidus_select" custom element
  # @see "admin/app/javascript/solidus_admin/web_components/solidus_select.js"
  # @param choices [Array<String>, Array<Array<String>>] container with options to be rendered
  #   (see `ActionView::Helpers::FormOptionsHelper#options_for_select`).
  #   When +:src+ parameter is provided, use +:choices+ to provide the list of selected options only.
  # @param src [nil, String] URL of a JSON resource with options data to be loaded instead of rendering options in place.
  # @option attributes [nil, String, Integer, Array<String, Integer>] :value which option should be selected
  # @option attributes [String] :"data-option-value-field"
  # @option attributes [String] :"data-option-label-field" when +:src+ param is passed, value and label of loaded options
  #   will be mapped to JSON response +"id"+ and +"name"+ by default. Use these parameters to map to different keys.
  # @option attributes [String] :"data-json-path" when +:src+ param is passed and options data is nested in JSON response,
  #   specify path to it with this parameter.
  # @option attributes [String] :"data-query-param" when +:src+ param is passed, use this parameter to specify the name of
  #   a query parameter to be used with search, e.g.:
  #   ```
  #   src: solidus_admin.countries_url,
  #   "data-query-param": "q[name_cont]",
  #   ```
  # @option attributes [String] :"data-no-preload" when +:src+ param is passed, options are preloaded when the component
  #   is initialized. Use this option to disable preload.
  # @option attributes [String] :"data-loading-message" when +:src+ param is passed, which text to show while loading options.
  #   Default: "Loading".
  # @option attributes [String] :"data-loading-more-message" when +:src+ param is passed, which text to show while
  #   loading next page of results. Default: "Loading more results".
  # @option attributes [String] :"data-no-results-message" which text to show when there are no search results returned.
  #   Default: "No results found".
  # @option attributes [true, String] :include_blank if passed, an empty option will be prepended to the list of options.
  #   Pass +true+ for empty option with no text, or +String+ for the text to be shown as empty option.
  # @raise [ArgumentError] if +choices+ is not an array
  def initialize(label:, name:, choices:, src: nil, size: :m, hint: nil, tip: nil, error: nil, **attributes)
    @label = label
    @hint = hint
    @tip = tip
    @error = Array.wrap(error)
    @attributes = attributes

    prepare_options(choices:, src:)
    prepare_classes(size:)

    @attributes[:name] = name
    @attributes[:is] = "solidus-select"
    @attributes[:id] ||= "#{stimulus_id}_#{name}"
    @attributes[:"data-error-message"] = @error.presence
  end

  private

  # translations are not available at initialization so need to define them here
  def before_render
    @attributes[:"data-loading-message"] ||= t("solidus_admin.solidus_select.loading")
    @attributes[:"data-loading-more-message"] ||= t("solidus_admin.solidus_select.loading_more")
    @attributes[:"data-no-results-message"] ||= t("solidus_admin.solidus_select.no_results")
  end

  def prepare_options(choices:, src:)
    raise ArgumentError, "`choices` must be an array" unless choices.is_a?(Array)

    if src.present?
      @attributes[:"data-src"] = src
    end

    if (blank_option = @attributes.delete(:include_blank))
      blank_option = "" if blank_option == true
      choices.unshift([blank_option, ""])
    end

    @options_collection = options_for_select(choices, @attributes.delete(:value))
  end

  def prepare_classes(size:)
    general_classes = ["w-full relative text-black font-normal #{FONT_SIZES[size]}"]
    control_classes = ["[&>.control]:peer-invalid:border-red-600 [&>.control]:peer-invalid:hover:border-red-600
      [&>.control]:peer-invalid:text-red-600 [&>.control]:flex [&>.control]:flex-wrap [&>.control]:items-center
      [&>.control]:gap-1 [&>.control]:rounded-sm [&>.control]:w-full [&>.control]:rounded-sm [&>.control]:pl-3
      [&>.control]:pr-10 [&>.control]:py-1.5 [&>.control]:bg-white [&>.control]:border [&>.control]:border-gray-300
      [&>.control]:hover:border-gray-500 [&>.control]:has-[:disabled]:bg-gray-50 [&>.control]:has-[:disabled]:text-gray-500
      [&>.control]:has-[:disabled]:cursor-not-allowed [&>.control]:has-[:disabled]:hover:border-gray-300
      [&>.control]:has-[:focus]:ring [&>.control]:has-[:focus]:ring-gray-300 [&>.control]:has-[:focus]:ring-0.5
      [&>.control]:has-[:focus]:bg-white [&>.control]:has-[:focus]:ring-offset-0 [&>.control]:has-[:focus]:outline-none
      #{HEIGHTS[:control][size]}"]

    unless @attributes[:multiple]
      control_classes << "[&>.control]:peer-invalid:bg-arrow-down-s-fill-red-400 [&>.control]:form-select
        [&>.control]:bg-arrow-down-s-fill-gray-700"
    end

    item_classes = []
    if @attributes[:multiple]
      item_classes << "[&_.item]:flex [&_.item]:gap-1 [&_.item]:items-center [&_.item]:rounded-full [&_.item]:whitespace-nowrap
        [&_.item]:px-2 [&_.item]:py-0.5 [&_.item]:bg-graphite-light [&_.item]:peer-invalid:bg-red-100 #{HEIGHTS[:item][size]}
        [&_.item_.remove-button]:text-xl [&_.item_.remove-button]:pb-0.5 [&_.item_.remove-button]:order-first
        [&_.item_.remove-button]:has-[:disabled]:cursor-not-allowed"
    end

    input_classes = ["[&_input]:has-[.item]:placeholder:opacity-0 [&_input:disabled]:cursor-not-allowed [&_input:disabled]:bg-gray-50
      [&_input]:peer-invalid:placeholder:text-red-400"]

    unless @attributes[:multiple]
      input_classes << "[&_input]:has-[.item]:opacity-0 [&_input]:has-[.item]:cursor-default"
    end

    dropdown_classes = ["[&_.dropdown]:w-full [&_.dropdown]:absolute [&_.dropdown]:border [&_.dropdown]:border-gray-100
      [&_.dropdown]:mt-0.5 [&_.dropdown]:min-w-[10rem] [&_.dropdown]:p-2 [&_.dropdown]:rounded-sm [&_.dropdown]:z-10
      [&_.dropdown]:shadow-lg [&_.dropdown]:bg-white"]

    dropdown_content_classes = ["[&_.dropdown-content]:flex [&_.dropdown-content]:flex-col [&_.dropdown-content]:max-h-[200px]
      [&_.dropdown-content]:overflow-x-hidden [&_.dropdown-content]:overflow-y-auto [&_.dropdown-content]:scroll-smooth
      [&_.no-results]:text-gray-500 [&_.no-results]:px-2 [&_.no-results]:py-1
      [&_.loading]:animate-pulse [&_.loading]:italic [&_.loading]:text-gray-500 [&_.loading]:px-2 [&_.loading]:py-1"]

    option_classes = ["[&_.option]:p-2 [&_.option]:rounded-sm [&_.option]:min-w-fit [&_.option.active]:bg-gray-50
      [&_.option.active]:text-gray-700 [&_.option_.highlight]:bg-yellow [&_.option_.highlight]:rounded-[1px]
      [&_.option.loading-more]:animate-pulse [&_.option.loading-more]:italic [&_.option.loading-more]:text-gray-500 [&_.option.loading-more]:text-center [&_.option.loading-more]:text-xs [&_.option.loading-more]:py-0.5 [&_.option.loading-more]:pointer-events-none
      #{HEIGHTS[:option][size]}"]

    @attributes[:class] = [
      "peer",
      general_classes,
      control_classes,
      item_classes,
      input_classes,
      dropdown_classes,
      dropdown_content_classes,
      option_classes,
      @attributes[:class]
    ].compact.join(" ")
  end
end
