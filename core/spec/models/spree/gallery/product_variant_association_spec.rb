require 'spec_helper'
require 'spree/testing_support/shared_examples/gallery'

RSpec.describe Spree::Gallery::ProductVariantAssociation, type: :model do
  let(:gallery) { described_class.new(product) }

  let(:product) { Spree::Product.new }

  include_examples 'is a gallery'

  shared_context 'has multiple images' do
    let(:first_image) { Spree::Image.new }
    let(:second_image) { Spree::Image.new }

    before do
      product.images << first_image
      product.images << second_image
    end
  end

  describe '#images' do
    subject { product.images }

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

  shared_examples_for 'image picking' do
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

    context 'with non-master variant with images' do
      let(:product) { create :product }
      let(:variant) { create :variant, product: product }
      let!(:image) { create :image, viewable: variant }

      it 'falls back to the products image' do
        expect(subject).to eq image
      end
    end
  end

  describe '#primary_image' do
    include_examples 'image picking'
  end

  describe '#best_image' do
    include_examples 'image picking'
  end

  describe '.preload_params' do
    it 'uses the right preload_params' do
      expect(described_class.preload_params).to eq [:variant_images]
    end

    it 'is valid on products' do
      create :product
      expect(Spree::Product.includes(described_class.preload_params).first).to be
    end
  end
end
