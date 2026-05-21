require "solidus_starter_frontend_spec_helper"

RSpec.describe ImageComponent, type: :component do
  let(:page_image) { page.find('img') }

  context 'when rendered' do
    def assets_prefix
      @assets_prefix ||= Rails.application.config.assets.prefix
    end

    before do
      render_inline(described_class.new(arguments))
    end

    context 'when no arguments are provided' do
      let(:arguments) { { } }

      it 'renders a placeholder' do
        expect(page).to have_selector('div.image-placeholder.mini')
      end
    end

    context 'when an image is provided' do
      let(:alt) { 'some-alt' }
      let(:image) { build(:image, alt: alt) }
      let(:arguments) { { image: image } }

      context 'when the image has an alt' do
        let(:alt) { 'some-alt' }

        it 'renders the image' do
          expect(page_image['alt']).to eq(alt)
          expect(page_image['src']).to match(%r{#{assets_prefix}/noimage/mini-.*.png})
        end
      end

      context 'when the image does not have an alt' do
        let(:alt) { nil }

        it 'renders the image' do
          expect(page_image['alt']).to be_nil
          expect(page_image['src']).to match(%r{#{assets_prefix}/noimage/mini-.*.png})
        end
      end
    end

    context 'when all the required arguments are provided' do
      let(:arguments) do
        {
          image: build(:image),
          size: :small,
          itemprop: 'some-itemprop',
          classes: ['some-class'],
          data: { key: 'value' },
        }
      end

      it 'renders the image' do
        expect(page_image['class']).to eq('some-class')
        expect(page_image['itemprop']).to eq('some-itemprop')
        expect(page_image['data-key']).to eq('value')
        expect(page_image['src']).to match(%r{#{assets_prefix}/noimage/small-.*.png})
      end
    end
  end
end
