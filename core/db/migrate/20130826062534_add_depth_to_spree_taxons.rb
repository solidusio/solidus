class AddDepthToSpreeTaxons < ActiveRecord::Migration[4.2]
  def up
    add_column :spree_taxons, :depth, :integer

    say_with_time 'Update depth on all taxons' do
      Spree::Taxon.reset_column_information
      Spree::Taxon.all.each(&:save)
    end
  end

  def down
    remove_column :spree_taxons, :depth
  end
end
