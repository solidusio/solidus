module Spree
  class Taxonomy < Spree::Base
    acts_as_list

    validates :name, presence: true

    has_many :taxons, inverse_of: :taxonomy
    has_one :root, -> { where parent_id: nil }, class_name: "Spree::Taxon", dependent: :destroy

    after_save :set_name

    default_scope -> { order(:position) }

    private

    def set_name
      if root
        root.update_columns(
          name: name,
          updated_at: Time.current
        )
      else
        self.root = Taxon.create!(taxonomy_id: id, name: name)
      end
    end
  end
end
