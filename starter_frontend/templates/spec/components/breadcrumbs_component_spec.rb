# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe BreadcrumbsComponent, type: :component do
  let(:request_url) { '/' }

  let(:breadcrumb_items) do
    page.all('a[itemprop=item]').map(&:text)
  end

  shared_context 'with no taxon and no order' do
    let(:taxon) { nil }
    let(:order) { nil }
  end

  shared_context 'with taxon' do
    let(:taxon) { create(:taxon, name: 'some taxon') }
    let(:order) { nil }
  end

  shared_context 'with order' do
    let(:order) { create(:order) }
    let(:taxon) { nil }
  end

  context 'when rendered' do
    before do
      with_request_url(request_url) do
        render_inline(described_class.new(taxon: taxon, order: order))
      end
    end

    context 'when the taxon is nil' do
      include_context 'with no taxon and no order'

      it 'does not render any breadcrumb items' do
        expect(breadcrumb_items.size).to eq(0)
      end
    end

    context 'when the taxon is present' do
      include_context 'with taxon'

      context 'when the current page is the root page' do
        let(:request_url) { '/' }

        it 'does not render any breadcrumb items' do
          expect(breadcrumb_items.size).to eq(0)
        end
      end

      context 'when the current page is not the root page' do
        let(:request_url) { '/products' }

        it 'renders a breadcrumb for the taxon and its ancestors' do
          expect(breadcrumb_items.size).to eq(4)
          expect(breadcrumb_items[-4]).to eq('Home')
          expect(breadcrumb_items[-3]).to eq('Products')
          expect(breadcrumb_items[-2]).to eq(taxon.parent.name) # default taxonomy taxon root
          expect(breadcrumb_items[-1]).to eq(taxon.name)
        end
      end
    end

    context 'when the current page is login' do
      include_context 'with no taxon and no order'
      let(:request_url) { '/login' }

      it 'renders a breadcrumb for login page' do
        expect(breadcrumb_items.size).to eq(2)
        expect(breadcrumb_items[-2]).to eq('Home')
        expect(breadcrumb_items[-1]).to eq('Login')
      end
    end

    context 'when the current page is account' do
      include_context 'with no taxon and no order'
      let(:request_url) { '/account' }

      it 'renders a breadcrumb for account page' do
        expect(breadcrumb_items.size).to eq(2)
        expect(breadcrumb_items[-2]).to eq('Home')
        expect(breadcrumb_items[-1]).to eq('Account')
      end
    end

    context 'when the current page is account edit' do
      include_context 'with no taxon and no order'
      let(:request_url) { '/account/edit' }

      it 'renders a breadcrumb for account edit page' do
        expect(breadcrumb_items.size).to eq(3)
        expect(breadcrumb_items[-3]).to eq('Home')
        expect(breadcrumb_items[-2]).to eq('Account')
        expect(breadcrumb_items[-1]).to eq('Edit')
      end
    end

    context 'when the current page is cart' do
      include_context 'with no taxon and no order'
      let(:request_url) { '/cart' }

      it 'renders a breadcrumb for cart page' do
        expect(breadcrumb_items.size).to eq(2)
        expect(breadcrumb_items[-2]).to eq('Home')
        expect(breadcrumb_items[-1]).to eq('Cart')
      end
    end

    context 'when the current page is sign up' do
      include_context 'with no taxon and no order'
      let(:request_url) { '/signup' }

      it 'renders a breadcrumb for sign up page' do
        expect(breadcrumb_items.size).to eq(2)
        expect(breadcrumb_items[-2]).to eq('Home')
        expect(breadcrumb_items[-1]).to eq('Sign Up')
      end
    end

    context 'when the current page is password recovery' do
      include_context 'with no taxon and no order'
      let(:request_url) { '/password/recover' }

      it 'renders a breadcrumb for password recovery page' do
        expect(breadcrumb_items.size).to eq(2)
        expect(breadcrumb_items[-2]).to eq('Home')
        expect(breadcrumb_items[-1]).to eq('Forgot Password?')
      end
    end

    context 'when the current page is product index' do
      include_context 'with no taxon and no order'
      let(:request_url) { '/products' }

      it 'renders a breadcrumb for product index page' do
        expect(breadcrumb_items.size).to eq(2)
        expect(breadcrumb_items[-2]).to eq('Home')
        expect(breadcrumb_items[-1]).to eq('Products')
      end
    end

    context 'when the current page is checkout' do
      include_context 'with no taxon and no order'
      let(:request_url) { '/checkout' }

      it 'renders a breadcrumb for checkout page' do
        expect(breadcrumb_items.size).to eq(2)
        expect(breadcrumb_items[-2]).to eq('Home')
        expect(breadcrumb_items[-1]).to eq('Checkout')
      end
    end

    context 'when the current page is order show page' do
      include_context 'with order'
      let(:request_url) { "/orders/#{order.number}" }

      it 'renders a breadcrumb for order show page' do
        expect(breadcrumb_items.size).to eq(3)
        expect(breadcrumb_items[-3]).to eq('Home')
        expect(breadcrumb_items[-2]).to eq('Orders')
        expect(breadcrumb_items[-1]).to eq(order.number)
      end
    end
  end
end
