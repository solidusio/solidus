require "solidus_starter_frontend_spec_helper"

RSpec.describe LinkToCartComponent, type: :component do
  let(:text) { '' }

  let(:link_to_cart_component) do
    described_class.new(text)
  end

  let(:current_order) { nil }

  context 'when rendered' do
    before do
      expect(link_to_cart_component)
        .to receive(:current_order).at_least(:once).and_return(current_order)

      render_inline(link_to_cart_component)
    end

    describe 'concerning current_order' do
      context 'when current_order is nil' do
        let(:current_order) { nil }

        it 'renders an empty cart' do
          link = page.find('a.cart-info')

          aggregate_failures do
            expect(link).to_not be_nil
            expect(link.text).to be_empty
          end
        end
      end

      context 'when there is a current order' do
        let(:line_items_count) { 0 }
        let(:current_order) { create(:order_with_line_items, line_items_count: line_items_count) }

        context 'when the current order has no items' do
          let(:line_items_count) { 0 }

          it 'renders an empty cart' do
            expect(page.find('a.cart-info').text).to be_empty
          end
        end

        context 'when the current order has an item' do
          let(:line_items_count) { 1 }

          it 'renders a cart with its item count' do
            expect(page.find('a.cart-info.full .link-text'))
              .to have_content(line_items_count)
          end
        end
      end
    end
  end
end
