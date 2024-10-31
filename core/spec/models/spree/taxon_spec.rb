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
        let(:taxon) { create(:taxon, :with_icon) }

        it "removes the attachment" do
          expect(taxon.destroy_attachment(:icon)).to be_truthy
        end

        if Spree::Config.taxon_attachment_module == Spree::Taxon::PaperclipAttachment
          it "returns false if destroying the attachment fails" do
            allow(taxon.icon).to receive(:destroy).and_return(false)
            expect(taxon.destroy_attachment(:icon)).to be_falsey
          end

          it "resets paperclip attributes when using Paperclip", aggregate_failures: true do
            expect(taxon.destroy_attachment(:icon)).to be_truthy
            expect(taxon.reload.icon_file_name).to_not be_present
            expect(taxon.reload.icon_content_type).to_not be_present
            expect(taxon.reload.icon_file_size).to_not be_present
            expect(taxon.reload.icon_updated_at).to_not be_present
          end
        end
      end

      context "and the taxon does not have any file attached yet" do
        let(:taxon) { create(:taxon) }

        it "returns false" do
          expect(taxon.destroy_attachment(:icon)).to be_falsey
        end
      end
    end

    context "when trying to destroy an invalid attachment" do
      let(:taxon) { create(:taxon) }

      it 'returns false' do
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
    let(:taxonomy) { create(:taxonomy, name: "Ruby on Rails") }
    let(:taxon) { taxonomy.root }

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
      before       { allow(taxon).to receive_messages(parent:) }

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
    let(:taxon1) { create(:taxon, name: 't1', taxonomy:, parent: root) }
    let(:taxon2) { create(:taxon, name: 't2', taxonomy:, parent: root) }
    let(:taxon2_child) { create(:taxon, name: 't2_child', taxonomy:, parent: taxon2) }

    context "changing parent" do
      subject { taxon2.update!(parent: taxon1) }

      it "changes own permalink" do
        expect { subject }.to change{ taxon2.reload.permalink }.from('t/t2').to('t/t1/t2')
      end

      it "changes child's permalink" do
        expect { subject }.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/t1/t2/t2_child')
      end
    end

    context "changing own permalink" do
      subject { taxon2.update!(permalink: 'foo') }

      it "changes own permalink" do
        expect { subject }.to change{ taxon2.reload.permalink }.from('t/t2').to('t/foo')
      end

      it "changes child's permalink" do
        expect { subject }.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/foo/t2_child')
      end
    end

    context "changing own permalink part" do
      subject { taxon2.update!(permalink_part: 'foo') }

      it "changes own permalink" do
        expect { subject }.to change{ taxon2.reload.permalink }.from('t/t2').to('t/foo')
      end

      it "changes child's permalink" do
        expect { subject }.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/foo/t2_child')
      end
    end

    context "changing parent and own permalink" do
      subject { taxon2.update!(parent: taxon1, permalink: 'foo') }

      it "changes own permalink" do
        expect { subject }.to change{ taxon2.reload.permalink }.from('t/t2').to('t/t1/foo')
      end

      it "changes child's permalink" do
        expect { subject }.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/t1/foo/t2_child')
      end
    end

    context 'changing parent permalink with special characters ' do
      subject { taxon2.update!(permalink: 'spécial&charactèrs') }

      it 'changes own permalink with parameterized characters' do
        expect { subject }.to change{ taxon2.reload.permalink }.from('t/t2').to('t/special-characters')
      end

      it 'changes child permalink with parameterized characters' do
        expect { subject }.to change{ taxon2_child.reload.permalink }.from('t/t2/t2_child').to('t/special-characters/t2_child')
      end
    end
  end

  context "validations" do
    context "taxonomy_id validations" do
      let(:taxonomy) { create(:taxonomy) }

      it "ensures that only one root can be created" do
        taxon = taxonomy.taxons.create(name: 'New node')
        expect(taxon).to be_invalid
        expect(taxon.errors.full_messages).to match_array(["Taxonomy can only have one root Taxon"])
      end

      it "allows for multiple taxons under a taxonomy" do
        taxon = taxonomy.root.children.create!(name: 'First child', taxonomy:)
        expect(taxon).to be_valid
        expect(taxonomy.taxons.many?).to eq(true)
        second_taxon = taxonomy.root.children.create!(name: 'Second child', taxonomy:)
        expect(second_taxon).to be_valid
        expect(taxonomy.root.children.many?).to eq(true)
      end

      # Regression test https://github.com/solidusio/solidus/issues/5187
      it "does not invalidate the root taxon after having children taxons" do
        taxonomy.root.children.create!(name: 'New node', taxonomy:)
        expect(taxonomy.taxons.many?).to eq(true)
        expect(taxonomy.root).to be_valid
      end
    end

    context "name validations" do
      let!(:taxonomy) { create(:taxonomy) }
      let!(:taxon_level_one) { create(:taxon, name: 'Solidus', parent: taxonomy.root) }
      let(:taxon_level_one_duplicate) { build(:taxon, name: 'Solidus', parent: taxonomy.root) }
      let(:taxon_level_two) { create(:taxon, name: 'Solidus', parent: taxon_level_one) }

      it "ensures that taxons with the same parent must have unique names" do
        expect(taxon_level_one_duplicate.save).to eq(false)
        expect(taxon_level_one_duplicate.errors.full_messages).to match_array(["Name must be unique under the same parent Taxon"])
      end

      it "allows for multiple taxons with the same name under different parents" do
        expect(taxon_level_two).to be_valid
      end
    end
  end

  context 'leaves of the taxon tree' do
    let(:taxonomy) { create(:taxonomy, name: 't') }
    let(:root) { taxonomy.root }
    let(:taxon) { create(:taxon, name: 't1', taxonomy:, parent: root) }
    let(:child) { create(:taxon, name: 'child taxon', taxonomy:, parent: taxon) }
    let(:grandchild) { create(:taxon, name: 'grandchild taxon', taxonomy:, parent: child) }
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
