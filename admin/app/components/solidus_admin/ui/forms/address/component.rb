# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Component < SolidusAdmin::BaseComponent
  DefaultNamedFieldsetNotFound = Class.new(NameError)

  include SolidusAdmin::SlotableDefault

  renders_one :fieldset

  # @param fieldset [Symbol] use a default named fieldset, component of the same name must be defined
  #   in "ui/forms/address/fieldsets"
  # @param extends [Array<Symbol, Hash{Symbol => #call}>] extend default fieldset,
  #   see +SolidusAdmin::UI::Forms::Address::Fieldsets::Base+
  # @param excludes [Array<Symbol>, Symbol] optionally exclude fields that are present in a default fieldset
  # @raise [DefaultNamedFieldsetNotFound] if the provided +:fieldset+ option does not correspond to a defined component
  #   in "ui/forms/address/fieldsets"
  def initialize(addressable:, form_field_name:, disabled: false, fieldset: :contact, extends: [], excludes: [])
    @disabled = disabled
    @default_fieldset = fieldset_component(fieldset).new(
      addressable:,
      form_field_name:,
      extends:,
      excludes:
    )
  end

  attr_reader :default_fieldset

  private

  def fieldset_component(fieldset)
    component("ui/forms/address/fieldsets/#{fieldset}")
  rescue SolidusAdmin::ComponentRegistry::ComponentNotFoundError
    raise DefaultNamedFieldsetNotFound,
      "to use a default named fieldset `#{fieldset}` you must implement a component in 'ui/forms/address/fieldsets/#{fieldset}'"
  end
end
