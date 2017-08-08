# frozen_string_literal: true

module Spree
  class QuickSwitchItem
    attr_reader :search_triggers, :finder, :url, :help_text_key, :not_found_text_key

    # @param search_triggers [Array<Symbol>] An array of symbols that will be
    #   entered as a part the administrators search that will trigger this
    #   particular search query to run
    # @param finder [Proc] A function to find the resource
    # @param url [Proc] A function to return the URL we should redirect to
    # @param help_text_key [Symbol] The key for the help text defined in i18n
    # @param not_found_text_key [Symbol] The key for the 404 text defined in i18n
    #
    # @example
    #   Spree::QuickSwitchItem.new(
    #     search_triggers: [:o, :order],
    #     finder: ->(searched_value) do
    #       Spree::Order.find_by(number: searched_value)
    #     end,
    #     url: ->(order) do
    #       Spree::Core::Engine.routes.url_helpers.edit_admin_order_path(order)
    #     end,
    #     help_text_key: :order_help,
    #     not_found_text_key: :order_not_found
    #   )
    def initialize(
      search_triggers:,
      finder:,
      url:,
      help_text_key:,
      not_found_text_key:
    )
      @search_triggers = search_triggers
      @finder = finder
      @url = url
      @help_text_key = help_text_key
      @not_found_text_key = not_found_text_key
    end

    def help_text
      I18n.t(@help_text_key, scope: "spree.quick_switch")
    end

    def not_found_text(value)
      I18n.t(@not_found_text_key, scope: "spree.quick_switch", value: value)
    end
  end
end
