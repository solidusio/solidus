# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Select::Component < SolidusAdmin::BaseComponent
  FONT_SIZES = {
    control: {
      s: "[&>.control]:text-xs",
      m: "[&>.control]:text-sm",
      l: "[&>.control]:text-base",
    },
    dropdown: {
      s: "text-xs",
      m: "text-sm",
      l: "text-base",
    },
  }.freeze

  HEIGHTS = {
    control: {
      s: "[&>.control]:min-h-7",
      m: "[&>.control]:min-h-9",
      l: "[&>.control]:min-h-12",
    },
    option: {
      s: "h-7",
      m: "h-9",
      l: "h-12",
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
    @attributes[:"data-error-message"] = @error.presence

    general_classes = ["w-full relative text-black font-normal"]
    control_classes = ["[&>.control]:peer-invalid:border-red-600 [&>.control]:peer-invalid:hover:border-red-600
      [&>.control]:peer-invalid:text-red-600 [&>.control]:flex [&>.control]:flex-wrap [&>.control]:items-center
      [&>.control]:gap-1 [&>.control]:rounded-sm [&>.control]:w-full [&>.control]:rounded-sm [&>.control]:pl-3
      [&>.control]:pr-10 [&>.control]:py-1.5 [&>.control]:bg-white [&>.control]:border [&>.control]:border-gray-300
      [&>.control]:hover:border-gray-500 [&>.control]:has-[:disabled]:bg-gray-50 [&>.control]:has-[:disabled]:text-gray-500
      [&>.control]:has-[:disabled]:cursor-not-allowed [&>.control]:has-[:disabled]:hover:border-gray-300
      [&>.control]:has-[:focus]:ring [&>.control]:has-[:focus]:ring-gray-300 [&>.control]:has-[:focus]:ring-0.5
      [&>.control]:has-[:focus]:bg-white [&>.control]:has-[:focus]:ring-offset-0 [&>.control]:has-[:focus]:outline-none
      #{HEIGHTS[:control][size]} #{FONT_SIZES[:control][size]}"]

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

    unless @attributes[:multiple]
      input_classes << "[&_input]:has-[.item]:opacity-0 [&_input]:has-[.item]:cursor-default"
    end

    @attributes[:class] = [
      "peer",
      general_classes,
      control_classes,
      item_classes,
      input_classes,
      @attributes[:class]
    ].compact.join(" ")

    @attributes[:"dropdown-class"] = "w-full absolute border border-gray-100 mt-0.5 min-w-[10rem] p-2 rounded-sm z-10 shadow-lg bg-white #{FONT_SIZES[:dropdown][size]}"
    @attributes[:"dropdown-content-class"] = "flex flex-col max-h-[200px] overflow-x-hidden overflow-y-auto scroll-smooth [&_.no-results]:text-gray-500"
    @attributes[:"option-class"] = "p-2 rounded-sm min-w-fit [&.active]:bg-gray-50 [&.active]:text-gray-700 [&_.highlight]:bg-yellow [&_.highlight]:rounded-[1px] #{HEIGHTS[:option][size]}"
  end
end
