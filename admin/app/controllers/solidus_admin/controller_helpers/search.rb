# frozen_string_literal: true

module SolidusAdmin::ControllerHelpers::Search
  extend ActiveSupport::Concern

  private

  def apply_search_to(relation, param:)
    apply_ransack_search_to(relation, param: param)
  end

  def apply_ransack_search_to(relation, param:)
    relation
      .ransack(params[param]&.except(:scope))
      .result(distinct: true)
  end
end
