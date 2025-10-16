# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::TouchTaxonsJob, type: :job do
  let(:taxonomy) { create(:taxonomy) }
  let(:root_taxon) { create(:taxon, taxonomy: taxonomy) }
  let(:child_taxon) { create(:taxon, parent: root_taxon, taxonomy: taxonomy) }
  let(:grandchild_taxon) { create(:taxon, parent: child_taxon, taxonomy: taxonomy) }

  # Helper to count db hits
  def count_queries(&block)
    queries = []
    subscription = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
      queries << payload[:sql] if payload[:sql] =~ /^\s*(SELECT|UPDATE|INSERT|DELETE)/i
    end
    
    block.call
    
    ActiveSupport::Notifications.unsubscribe(subscription)
    queries.size
  end

  describe '#perform' do
    context 'with empty taxon_ids' do
      it 'does not update any timestamps' do
        original_time = root_taxon.updated_at

        described_class.perform_now([])

        expect(root_taxon.reload.updated_at).to eq(original_time)
      end

      it 'executes no queries' do
        query_count = count_queries do
          described_class.perform_now([])
        end

        expect(query_count).to eq(0)
      end
    end

    context 'with single taxon' do
      it 'updates the taxon timestamp' do
        original_time = root_taxon.updated_at

        described_class.perform_now([root_taxon.id])

        expect(root_taxon.reload.updated_at).to be > original_time
      end

      it 'updates the taxonomy timestamp' do
        original_time = taxonomy.updated_at

        described_class.perform_now([root_taxon.id])

        expect(taxonomy.reload.updated_at).to be > original_time
      end
    end

    context 'with child taxon' do
      it 'updates child and all ancestors' do
        original_root_time = root_taxon.updated_at
        original_child_time = child_taxon.updated_at

        described_class.perform_now([child_taxon.id])

        expect(child_taxon.reload.updated_at).to be > original_child_time
        expect(root_taxon.reload.updated_at).to be > original_root_time
      end
    end

    context 'with grandchild taxon' do
      it 'updates grandchild and all ancestors (3 levels deep)' do
        original_root_time = root_taxon.updated_at
        original_child_time = child_taxon.updated_at
        original_grandchild_time = grandchild_taxon.updated_at

        described_class.perform_now([grandchild_taxon.id])

        expect(grandchild_taxon.reload.updated_at).to be > original_grandchild_time
        expect(child_taxon.reload.updated_at).to be > original_child_time
        expect(root_taxon.reload.updated_at).to be > original_root_time
      end
    end

    context 'with multiple taxons that share ancestors' do
      let(:another_root_taxon) { create(:taxon, taxonomy: taxonomy, name: 'Another Root') }
      let(:another_child_taxon) { create(:taxon, parent: another_root_taxon, taxonomy: taxonomy) }

      it 'updates all taxons and their ancestors' do
        original_root_time = root_taxon.updated_at
        original_child_time = child_taxon.updated_at
        original_another_root_time = another_root_taxon.updated_at
        original_another_child_time = another_child_taxon.updated_at
        original_taxonomy_time = taxonomy.updated_at

        described_class.perform_now([child_taxon.id, another_child_taxon.id])

        expect(child_taxon.reload.updated_at).to be > original_child_time
        expect(another_child_taxon.reload.updated_at).to be > original_another_child_time
        expect(root_taxon.reload.updated_at).to be > original_root_time
        expect(another_root_taxon.reload.updated_at).to be > original_another_root_time
        expect(taxonomy.reload.updated_at).to be > original_taxonomy_time
      end
    end

    context 'with multiple taxonomies' do
      let(:another_taxonomy) { create(:taxonomy) }
      let(:another_taxon) { create(:taxon, taxonomy: another_taxonomy) }

      it 'updates taxons and taxonomies across different taxonomies' do
        original_child_time = child_taxon.updated_at
        original_root_time = root_taxon.updated_at
        original_another_taxon_time = another_taxon.updated_at
        original_taxonomy_time = taxonomy.updated_at
        original_another_taxonomy_time = another_taxonomy.updated_at

        described_class.perform_now([child_taxon.id, another_taxon.id])

        expect(child_taxon.reload.updated_at).to be > original_child_time
        expect(root_taxon.reload.updated_at).to be > original_root_time
        expect(another_taxon.reload.updated_at).to be > original_another_taxon_time
        expect(taxonomy.reload.updated_at).to be > original_taxonomy_time
        expect(another_taxonomy.reload.updated_at).to be > original_another_taxonomy_time
      end
    end

    context 'when some taxon IDs do not exist' do
      it 'processes valid taxons and ignores invalid IDs' do
        original_time = root_taxon.updated_at

        described_class.perform_now([99999, root_taxon.id, 88888])

        expect(root_taxon.reload.updated_at).to be > original_time
      end
    end

    context 'performance optimization' do
      let!(:great_grandchild_taxon) { create(:taxon, parent: grandchild_taxon, taxonomy: taxonomy) }
      # Force eager loading to exclude setup queries from count
      before { child_taxon }

      it 'executes exactly 3 queries regardless of taxon count or depth' do
        query_count = count_queries do
          described_class.perform_now([child_taxon.id, grandchild_taxon.id, great_grandchild_taxon.id])
        end
        
        expect(query_count).to eq(3), 'Should execute 1 SELECT + 2 UPDATEs'
      end
    end
  end
end
