# frozen_string_literal: true

module Taxonomies
  extend ActiveSupport::Concern
  included do
    helper_method :taxonomies
  end

  protected

  def taxonomies
    @taxonomies ||= Spree::Taxonomy.includes(root: :children)
  end
end
