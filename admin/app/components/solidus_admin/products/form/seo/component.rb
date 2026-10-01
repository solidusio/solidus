# frozen_string_literal: true

class SolidusAdmin::Products::Form::Seo::Component < SolidusAdmin::BaseComponent
  def initialize(form:)
    @form = form
  end

  private

  def condition_options
    @condition_options ||= Spree::Variant.conditions.map do |key, value|
      [t("spree.condition.#{key}"), value]
    end
  end
end
