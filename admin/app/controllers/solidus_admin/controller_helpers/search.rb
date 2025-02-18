# frozen_string_literal: true

module SolidusAdmin::ControllerHelpers::Search
  extend ActiveSupport::Concern

  module ClassMethods
    def search_scope(name, default: false, &block)
      search_scopes << SearchScope.new(
        name: name.to_s,
        block:,
        default:
      )
    end

    def search_scopes
      @search_scopes ||= []
    end
  end

  private

  def apply_search_to(relation, param:)
    relation = apply_scopes_to(relation, param:)
    apply_ransack_search_to(relation, param:)
  end

  def apply_ransack_search_to(relation, param:)
    relation
      .ransack(params[param]&.except(:scope))
      .result(distinct: true)
  end

  def apply_scopes_to(relation, param:)
    current_scope_name = params.dig(param, :scope)

    search_block = (
      self.class.search_scopes.find { _1.name == current_scope_name } ||
      self.class.search_scopes.find { _1.default }
    )&.block

    # Run the search if a block is present, fall back to the relation even if the
    # block is present but returns nil.
    (search_block && instance_exec(relation, &search_block)) || relation
  end

  SearchScope = Struct.new(:name, :block, :default, keyword_init: true)
  private_constant :SearchScope
end
