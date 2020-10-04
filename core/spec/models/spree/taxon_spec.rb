# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Taxon, type: :model do
  it_behaves_like 'an attachment' do
    subject { create(:taxon) }
    let(:attachment_name) { :icon }
    let(:default_style) { :mini }
  end

  context "#destroy" do
    subject(:nested_set_options) { described_class.acts_as_nested_set_options }

    it "should destroy all associated taxons" do
      expect(nested_set_options[:dependent]).to eq :destroy
    end
  end

  describe "#destroy_attachment" do
    context "when trying to destroy a valid attachment definition" do
      context "and taxon has a file attached " do
        it "removes the attachment" do
          taxon = create(:taxon, :with_icon)

          expect(taxon.destroy_attachment(:icon)).to be_truthy
        end
      end

      context "and the taxon does not have any file attached yet" do
        it "returns false" do
          taxon = create(:taxon)

          expect(taxon.destroy_attachment(:icon)).to be_falsey
        end
      end
    end

    context "when trying to destroy an invalid attachment" do
      it 'returns false' do
        taxon = create(:taxon)

        expect(taxon.destroy_attachment(:foo)).to be_falsey
      end
    end
  end

  describe '#to_param' do
    let(:taxon) { FactoryBot.build(:taxon, name: "Ruby on Rails") }

    subject { super().to_param }
    it { is_expected.to eql taxon.permalink }
  end

  context "set_permalink" do
    let(:taxon) { FactoryBot.build(:taxon, name: "Ruby on Rails") }

    it "should set permalink correctly when no parent present" do
      taxon.set_permalink
      expect(taxon.permalink).to eql "ruby-on-rails"
    end

    context "updating a taxon permalink" do
      it 'parameterizes permalink correctly' do
        taxon.save!
        taxon.update(permalink: 'spécial&charactèrs')
        expect(taxon.permalink).to eql "special-characters"
      end
    end

    context "with parent taxon" do
      let(:parent) { FactoryBot.build(:taxon, permalink: "brands") }
      before       { allow(taxon).to receive_messages parent: parent }

      it "should set permalink correctly when taxon has parent" do
        taxon.set_permalink
        expect(taxon.permalink).to eql "brands/ruby-on-rails"
      end

      it "should set permalink correctly with existing permalink present" do
        taxon.permalink = "b/rubyonrails"
        taxon.set_permalink
        expect(taxon.permalink).to eql "brands/rubyonrails"
      end

      it 'parameterizes permalink correctly' do
        taxon.save!
        taxon.update(permalink_part: 'spécial&charactèrs')
        expect(taxon.reload.permalink).to eql "brands/special-characters"
      end

      # Regression test for https://github.com/spree/spree/issues/3390
      context "setting a new node sibling position via :child_index=" do
        let(:idx) { rand(0..100) }
        before { allow(parent).to receive(:move_to_child_with_index) }

        context "taxon is not new" do
          before { allow(taxon).to receive(:new_record?).and_return(false) }

          it "passes the desired index move_to_child_with_index of :parent " do
            expect(taxon).to receive(:move_to_child_with_index).with(parent, idx)

            taxon.child_index = idx
          end
        end
      end
    end
  end

  context "updating permalink" do
    let(:taxonomy) { create(:taxonomy, name: 't') }
    let(:root) { taxonomy.root }
    let(:taxon1) { create(:taxon, name: 't1', taxonomy: taxonomy, parent: root) }
    let(:taxon2) { create(:taxon, name: 't2', taxonomy: taxonomy, parent: root) }
    let(:taxon2_child) { create(:taxon, name: 't2_child', taxonomy: taxonomy, parent: taxon2) }

    context "changing parent" do
      subject do
        -> { taxon2.update!(parent: taxon1) }
      end

      it "changes own permalink" do
        is_expected.to change{ taxon2.reload.permalink }.from('t/t2').to('t/t1/t2')
      end

      it "changes child's permalink" do
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/t1/t2/t2_child')
      end
    end

    context "changing own permalink" do
      subject do
        -> { taxon2.update!(permalink: 'foo') }
      end

      it "changes own permalink" do
        is_expected.to change{ taxon2.reload.permalink }.from('t/t2').to('t/foo')
      end

      it "changes child's permalink" do
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/foo/t2_child')
      end
    end

    context "changing own permalink part" do
      subject do
        -> { taxon2.update!(permalink_part: 'foo') }
      end

      it "changes own permalink" do
        is_expected.to change{ taxon2.reload.permalink }.from('t/t2').to('t/foo')
      end

      it "changes child's permalink" do
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/foo/t2_child')
      end
    end

    context "changing parent and own permalink" do
      subject do
        -> { taxon2.update!(parent: taxon1, permalink: 'foo') }
      end

      it "changes own permalink" do
        is_expected.to change{ taxon2.reload.permalink }.from('t/t2').to('t/t1/foo')
      end

      it "changes child's permalink" do
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/t1/foo/t2_child')
      end
    end

    context 'changing parent permalink with special characters ' do
      subject do
        -> { taxon2.update!(permalink: 'spécial&charactèrs') }
      end

      it 'changes own permalink with parameterized characters' do
        is_expected.to change{ taxon2.reload.permalink }.from('t/t2').to('t/special-characters')
      end

      it 'changes child permalink with parameterized characters' do
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/special-characters/t2_child')
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/2620
  context "creating a child node using first_or_create" do
    let(:taxonomy) { create(:taxonomy) }

    it "does not error out" do
      taxonomy.root.children.unscoped.where(name: "Some name").first_or_create
    end
  end

  context 'leaves of the taxon tree' do
    let(:taxonomy) { create(:taxonomy, name: 't') }
    let(:root) { taxonomy.root }
    let(:taxon) { create(:taxon, name: 't1', taxonomy: taxonomy, parent: root) }
    let(:child) { create(:taxon, name: 'child taxon', taxonomy: taxonomy, parent: taxon) }
    let(:grandchild) { create(:taxon, name: 'grandchild taxon', taxonomy: taxonomy, parent: child) }
    let(:product1) { create(:product) }
    let(:product2) { create(:product) }
    let(:product3) { create(:product) }
    before do
      product1.taxons << taxon
      product2.taxons << child
      product3.taxons << grandchild
      taxon.reload

      [product1, product2, product3].each { |p| 2.times.each { create(:variant, product: p) } }
    end

    describe '#all_products' do
      it 'returns all descendant products' do
        products = taxon.all_products
        expect(products.count).to eq(3)
        expect(products).to match_array([product1, product2, product3])
      end
    end

    describe '#all_variants' do
      it 'returns all descendant variants' do
        variants = taxon.all_variants
        expect(variants.count).to eq(9)
        expect(variants).to match_array([product1, product2, product3].flat_map(&:variants_including_master))
      end
    end
  end
end
