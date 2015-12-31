class AddDepthToSpreeTaxons < ActiveRecord::Migration
  def up
    if !Solidus::Taxon.column_names.include?('depth')
      add_column :spree_taxons, :depth, :integer

      say_with_time 'Update depth on all taxons' do
        Solidus::Taxon.reset_column_information
        Solidus::Taxon.all.each { |t| t.save }
      end
    end
  end

  def down
    remove_column :spree_taxons, :depth
  end
end
