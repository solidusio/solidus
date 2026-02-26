# frozen_string_literal: true

class SolidusAdmin::UI::Table::RansackFilter::Component < SolidusAdmin::BaseComponent
  # @param presentation [String] The label for the filter.
  # @param search_param [String] The search parameter for the filter query.
  # @param combinator [String] The combining logic for filter options.
  # @param attribute [String] The database attribute the filter is based on.
  # @param predicate [String] The comparison logic for the filter (e.g., "eq" for equals).
  # @param options [Proc] A callable that returns filter options.
  # @param index [Integer] The index of the filter.
  # @param form [String] The form in which the filter resides.
  def initialize(
    presentation:,
    combinator:, attribute:, predicate:, options:, form:, index:, search_param: :q
  )
    @presentation = presentation
    @group = "#{search_param}[g][#{index}]"
    @combinator = build(:combinator, combinator)
    @attribute = attribute
    @predicate = predicate
    @options = options
    @form = form
    @index = index
  end

  def before_render
    @selections = @options.map.with_index do |(label, value), opt_index|
      Selection.new(
        "#{stimulus_id}--#{label}-#{value}".parameterize,
        label,
        build(:attribute, @attribute, opt_index),
        build(:predicate, @predicate, opt_index),
        build(:option, value, opt_index),
        checked?(value)
      )
    end
  end

  # Builds form attributes for filter options.
  #
  # @param type [Symbol] The type of the form attribute.
  # @param value [String] The value of the form attribute.
  # @param opt_index [Integer] The index of the option, if applicable.
  # @return [FormAttribute] The built form attribute.
  def build(type, value, opt_index = nil)
    suffix = SUFFIXES[type] % {index: opt_index || @index}
    Attribute.new("#{@group}#{suffix}", value)
  end

  # Determines if a given value should be checked based on the params.
  #
  # @param value [String] The value of the checkbox.
  # @return [Boolean] Returns true if the checkbox should be checked, false otherwise.
  def checked?(value)
    conditions = params.dig(:q, :g, @index.to_s, :c)
    conditions && conditions.values.any? { |c| c[:v]&.include?(value.to_s) }
  end

  SUFFIXES = {
    combinator: "[m]",
    attribute: "[c][%<index>s][a][]",
    predicate: "[c][%<index>s][p]",
    option: "[c][%<index>s][v][]"
  }

  Selection = Struct.new(:id, :presentation, :attribute, :predicate, :option, :checked)
  Attribute = Struct.new(:name, :value)
end
