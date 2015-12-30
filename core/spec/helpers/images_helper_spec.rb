require 'spec_helper'

RSpec.describe Spree::ImagesHelper, type: :helper do
  describe '#image_or_default' do
    subject { helper.image_or_default(image) }

    let(:image) { nil }

    it 'is an image' do
      expect(subject).to be_a Spree::Image
    end

    context 'image is provided' do
      let(:image) { Spree::Image.new }

      it 'returns that image' do
        expect(subject).to be image
      end
    end
  end
  describe '#spree_image_tag' do
    subject { helper.spree_image_tag image, style, options}

    let(:image) { nil }
    let(:style) { :mini }
    let(:options) { {} }

    it 'uses default image' do
      expect(subject).to eq '<img src="/assets/noimage/mini.png" alt="Mini" />'
    end

    context 'given an image' do
      let(:image) { Spree::Image.new attachment_file_name: 'legit_image.png' }

      it 'uses the provided image' do
        expect(subject).to eq '<img src="/spree/products//mini/legit_image.png" alt="Legit image" />'
      end
    end

    context 'large style used' do
      let(:style) { :large }

      it 'uses default image with large style' do
        expect(subject).to eq '<img src="/assets/noimage/large.png" alt="Large" />'
      end
    end

    context 'with options provided' do
      let(:options) { { itemprop: 'image' } }

      it 'passes the options to image_tag' do
        expect(subject).to eq '<img itemprop="image" src="/assets/noimage/mini.png" alt="Mini" />'
      end
    end
  end
end
