# coding: UTF-8

require 'spec_helper'

describe Spree::Taxon, type: :model do
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

    it "should support Chinese characters" do
      taxon.name = "你好"
      taxon.set_permalink
      expect(taxon.permalink).to eql 'ni-hao'
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

      it "should support Chinese characters" do
        taxon.name = "我"
        taxon.set_permalink
        expect(taxon.permalink).to eql "brands/wo"
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
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2-child').to('t/t1/t2/t2-child')
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
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2-child').to('t/foo/t2-child')
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
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2-child').to('t/foo/t2-child')
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
        is_expected.to change{ taxon2_child.reload.permalink }.from('t/t2/t2-child').to('t/t1/foo/t2-child')
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
end
