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

  def initialize(label:, name:, choices:, size: :m, hint: nil, tip: nil, error: nil, **attributes)
    @label = label
    @name = name
    @hint = hint
    @tip = tip
    @error = Array.wrap(error)

    @choices = choices
    @selected = attributes.delete(:value)

    @attributes = attributes
    @attributes[:name] = @name
    @attributes[:is] = "solidus-select"
    @attributes[:id] ||= "#{stimulus_id}_#{@name}"

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

    input_classes = ["[&_input]:has-[.item]:placeholder:invisible [&_input:disabled]:cursor-not-allowed [&_input:disabled]:bg-gray-50
      [&_input]:peer-invalid:placeholder:text-red-400"]

    dropdown_classes = ["[&_.dropdown]:w-full [&_.dropdown]:absolute [&_.dropdown]:border [&_.dropdown]:border-gray-100
      [&_.dropdown]:mt-0.5 [&_.dropdown]:min-w-[10rem] [&_.dropdown]:p-2 [&_.dropdown]:rounded-sm [&_.dropdown]:z-10
      [&_.dropdown]:shadow-lg [&_.dropdown]:bg-white"]

    dropdown_content_classes = ["[&_.dropdown-content]:flex [&_.dropdown-content]:flex-col [&_.dropdown-content]:max-h-[200px]
      [&_.dropdown-content]:overflow-x-hidden [&_.dropdown-content]:overflow-y-auto [&_.dropdown-content]:scroll-smooth [&_.no-results]:text-gray-500"]

    option_classes = ["[&_.option]:p-2 [&_.option]:rounded-sm [&_.option]:min-w-fit [&_.option.active]:bg-gray-50
      [&_.option.active]:text-gray-700 [&_.option_.highlight]:bg-yellow [&_.option_.highlight]:rounded-[1px]
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

    merge_stimulus_data_attributes
  end

  private

  def merge_stimulus_data_attributes
    @attributes.deep_symbolize_keys!

    controllers = ["custom-validity"]
    actions = ["custom-validity#clearCustomValidity"]
    data_controller, data_action = @attributes.values_at(:"data-controller", :"data-action")

    controllers << data_controller
    actions << data_action

    if @attributes.key?(:data)
      data_controller = @attributes[:data].delete(:controller)
      data_action = @attributes[:data].delete(:action)
      controllers << data_controller
      actions << data_action
    end

    @attributes.merge!(
      "data-controller": controllers.compact.join(" "),
      "data-action": actions.compact.join(" "),
      "data-custom-validity-error-message-value": @error.presence,
    )
  end
end
