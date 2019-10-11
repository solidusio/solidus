# frozen_string_literal: true

module Solidus
  class Taxonomy < Solidus::Base
    acts_as_list

    validates :name, presence: true

    has_many :taxons, inverse_of: :taxonomy
    has_one :root, -> { where parent_id: nil }, class_name: "Solidus::Taxon", dependent: :destroy

    after_save :set_name

    default_scope -> { order(position: :asc) }

    self.whitelisted_ransackable_attributes = %w[name]

    private

    def set_name
      if root
        root.update_columns(
          name: name,
          updated_at: Time.current
        )
      else
        self.root = Solidus::Taxon.create!(taxonomy_id: id, name: name)
      end
    end
  end
end
