require 'spec_helper'
require 'spree/testing_support/shared_examples/gallery'

RSpec.describe Spree::Gallery::VariantAssociation, type: :model do
  let(:gallery) { described_class.new(variant) }

  let(:variant) { Spree::Variant.new }

  include_examples 'is a gallery'

  shared_context 'has multiple images' do
    let(:first_image) { Spree::Image.new }
    let(:second_image) { Spree::Image.new }

    before do
      variant.images << first_image
      variant.images << second_image
    end
  end

  describe '#images' do
    subject { gallery.images }

    it 'is empty' do
      expect(subject).to be_empty
    end

    context 'has multiple images' do

      include_context 'has multiple images'

      it 'has the images of the association' do
        expect(subject).to eq [first_image, second_image]
      end

    end
  end

  describe '#primary_image' do
    subject { gallery.primary_image }

    it 'is nil' do
      expect(subject).to be_nil
    end

    context 'has images' do
      include_context 'has multiple images'

      it 'uses the first image' do
        expect(subject).to eq first_image
      end
    end
  end

  describe '#best_image' do
    subject { gallery.best_image }

    it 'is nil' do
      expect(subject).to be_nil
    end

    context 'has images' do
      include_context 'has multiple images'

      it 'uses the first image' do
        expect(subject).to eq first_image
      end
    end

    context 'variant has a product' do
      let(:product) { Spree::Product.new }
      let(:variant) { Spree::Variant.new product: product }

      it 'is nil' do
        expect(subject).to be_nil
      end

      context 'that has images' do
        let(:product) { create :product }
        let(:variant) { create :variant, product: product }
        let!(:image) { create :image, viewable: product.master }

        it 'falls back to the products image' do
          expect(subject).to eq image
        end
      end
    end
  end

  describe '.preload_params' do
    it 'uses the right preload_params' do
      expect(described_class.preload_params).to eq [:images]
    end

    it 'is valid on products' do
      create :variant
      expect(Spree::Variant.includes(described_class.preload_params).first).to be
    end
  end
end
