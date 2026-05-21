# frozen_string_literal: true

class FilterComponent < ViewComponent::Base
  BASE_CLASS = 'filter'.freeze
  CSS_CLASS = "#{BASE_CLASS}__list mt-6".freeze

  attr_reader :filter, :search_params

  def initialize(filter:, search_params:)
    @filter = filter
    @search_params = search_params || {}
  end

  def call
    safe_join([filter_list_title, filter_list].compact) if filter_list
  end

  private

  def filter_list_title
    content_tag(:h6, title, class: "#{BASE_CLASS}__title font-sans-md") if title
  end

  def filter_list
    return @filter_list if @filter_list
    return if labels.empty?

    @filter_list = content_tag :ul, class: CSS_CLASS do
      safe_join(labels.map { |name, value| filter_list_item(name: name, value: value) })
    end
  end

  def filter_list_item(name:, value:)
    id = filter_list_item_id(name)

    content_tag(:li, class: 'checkbox-input mb-3') do
      concat check_box_tag(
        "search[#{filter[:scope].to_s}][]",
        value,
        filter_list_item_checked?(value),
        id: id)

      concat label_tag(id, name)
    end
  end

  def filter_list_item_id(name)
    sanitize_to_id("#{filter[:name]}_#{name}")
  end

  def filter_list_item_checked?(value)
    search_params[filter[:scope]]&.include?(value.to_s)
  end

  def title
    filter[:name]
  end

  def labels
    @labels ||= filter[:labels] || filter[:conds].map { |m,c| [m,m] }
  end
end
