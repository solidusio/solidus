class AddSeoMetasToTaxons < ActiveRecord::Migration
  def change
    change_table :solidus_taxons do |t|
      t.string   :meta_title
      t.string   :meta_description
      t.string   :meta_keywords
    end
  end
end
