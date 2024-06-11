# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/shared_examples/working_factory'

RSpec.describe 'taxon factory' do
  let(:factory_class) { Spree::Taxon }

  describe 'taxon' do
    let(:factory) { :taxon }

    it_behaves_like 'a working factory'

    context "when no taxonomy is given" do
      subject { create(:taxon) }

      before do
        # ensure that the subject is not accidentally
        # getting valid parent and taxonomy ids
        create(:taxon)
      end

      it "sets its taxonomy to created one and its parent to the taxonomy root" do
        expect(subject).to be_valid
        expect(subject.taxonomy).to be_present
        expect(subject.parent).to eq(subject.taxonomy.root)
        expect(subject).to_not eq(subject.taxonomy.root)
      end
    end

    context "when a taxonomy is given" do
      subject { create(:taxon, taxonomy: taxonomy) }

      let!(:taxonomy) { create(:taxonomy) }

      it "sets the taxonomy to the given one and its parent to the taxonomy root" do
        expect(subject).to be_valid
        expect(subject.taxonomy).to eq(taxonomy)
        expect(subject.parent).to eq(taxonomy.root)
      end
    end

    context "when a parent is given" do
      subject { create(:taxon, parent: parent_taxon) }

      let!(:parent_taxon) { create(:taxon) }

      it "sets the parent to the given one and its taxonomy to the parent's taxonomy" do
        expect(subject).to be_valid
        expect(subject.parent).to eq(parent_taxon)
        expect(subject.taxonomy).to eq(parent_taxon.taxonomy)
      end
    end
  end
end
