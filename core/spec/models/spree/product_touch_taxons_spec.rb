require "rails_helper"

RSpec.describe Spree::Product do
  describe "#touch_taxons" do
    let(:product) { create(:product) }

    before do
      taxonomy = create(:taxonomy)
      taxon_levels = 10
      taxons_per_level = 100
      parent_ids = []
      parent_id = taxonomy.root.id

      puts "\nCreating #{taxon_levels * taxons_per_level} taxons. Hold tight, this may take a while!\n"

      taxon_levels.times do
        taxons_per_level.times do
          taxon = create(:taxon, parent_id: parent_id)
          parent_ids << taxon.id
          print "."
        end
        parent_id = parent_ids.sample
      end

      puts "\nDone!"

      product.taxon_ids = Spree::Taxon.pluck(:id).sample(50)
    end

    subject { product.save(validate: false) }

    it "does not causes any errors" do
      expect(product.taxons.count).to eq(50)
      expect { subject }.to_not raise_error
    end

    it "is fast" do
      puts Benchmark.measure { subject }
    end
  end
end
