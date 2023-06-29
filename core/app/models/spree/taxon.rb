# frozen_string_literal: true

require 'spree/core/product_filters'

module Spree
  class Taxon < Spree::Base
    acts_as_nested_set dependent: :destroy

    belongs_to :taxonomy, class_name: 'Spree::Taxonomy', inverse_of: :taxons
    has_many :classifications, -> { order(:position) }, dependent: :delete_all, inverse_of: :taxon
    has_many :products, through: :classifications

    has_many :promotion_rule_taxons
    has_many :promotion_rules, through: :promotion_rule_taxons

    before_create :set_permalink
    before_update :set_permalink
    after_update :update_child_permalinks, if: :saved_change_to_permalink?

    validates :name, presence: true
    validates :name, uniqueness: { scope: :parent_id, message: :must_be_unique_under_same_parent }, if: -> { Spree::Config.extra_taxon_validations}
    validates :meta_keywords, length: { maximum: 255 }
    validates :meta_description, length: { maximum: 255 }
    validates :meta_title, length: { maximum: 255 }
    validates :taxonomy_id, uniqueness: { scope: :parent_id, message: :can_have_only_one_root }, if: -> { Spree::Config.extra_taxon_validations && root? }

    after_save :touch_ancestors_and_taxonomy
    after_touch :touch_ancestors_and_taxonomy

    include ::Spree::Config.taxon_attachment_module

    self.allowed_ransackable_attributes = %w[name]

    # @return [String] meta_title if set otherwise a string containing the
    #   root name and taxon name
    def seo_title
      if meta_title.present?
        meta_title
      else
        root? ? name : "#{root.name} - #{name}"
      end
    end

    # Sets this taxons permalink to a valid url encoded string based on its
    # name and its parents permalink (if present.)
    def set_permalink
      permalink_tail = permalink.present? ? permalink.split('/').last : name
      self.permalink_part = Spree::Config.taxon_url_parametizer_class.parameterize(permalink_tail)
    end

    # Update the permalink for this taxon and all children (if necessary)
    def update_permalinks
      set_permalink

      # This will trigger update_child_permalinks if permalink has changed
      save!
    end

    # Update the permalinks for all children
    def update_child_permalinks
      children.each(&:update_permalinks)
    end

    # @return [String] this taxon's permalink
    def to_param
      permalink
    end

    # @return [ActiveRecord::Relation<Spree::Product>] the active products the
    #   belong to this taxon
    def active_products
      products.not_deleted.available
    end

    # @return [ActiveRecord::Relation<Spree::Product>] all self and descendant products
    def all_products
      scope = Product.joins(:taxons)
      scope.where(
        spree_taxons: { id: self_and_descendants.select(:id) }
      )
    end

    # @return [ActiveRecord::Relation<Spree::Variant>] all self and descendant variants, including master variants.
    def all_variants
      Variant.where(product_id: all_products.select(:id))
    end

    # @return [String] this taxon's ancestors names followed by its own name,
    #   separated by arrows
    def pretty_name
      if parent.present?
        [
          parent.pretty_name,
          name
        ].compact.join(" -> ")
      else
        name
      end
    end

    # @see https://github.com/spree/spree/issues/3390
    def child_index=(idx)
      # awesome_nested_set sorts by :lft and :rgt. This call re-inserts the
      # child node so that its resulting position matches the observable
      # 0-indexed position.
      #
      # NOTE: no :position column needed - awesom_nested_set doesn't handle the
      # reordering if you bring your own :order_column.
      move_to_child_with_index(parent, idx.to_i) unless new_record?
    end

    def permalink_part
      permalink.split('/').last
    end

    def permalink_part=(value)
      if parent.present?
        self.permalink = "#{parent.permalink}/#{value}"
      else
        self.permalink = value
      end
    end

    private

    def touch_ancestors_and_taxonomy
      # Touches all ancestors at once to avoid recursive taxonomy touch, and reduce queries.
      self.class.default_scoped.where(id: ancestors.pluck(:id)).update_all(updated_at: Time.current)
      # Have taxonomy touch happen in #touch_ancestors_and_taxonomy rather than association option in order for imports to override.
      taxonomy.try!(:touch)
    end
  end
end
