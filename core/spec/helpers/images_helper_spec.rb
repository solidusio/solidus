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
end
