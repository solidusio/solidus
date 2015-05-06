require 'spec_helper'

module Spree
  module Admin
    describe TaxCategoriesController, type: :controller do
      stub_authorization!

      describe 'DELETE #destroy' do
        let(:tax_category) { create :tax_category }
        let(:format) { :html }

        subject { spree_delete :destroy, id: tax_category, format: format }

        context 'when destroy is successful' do
          context 'when format is html' do
            it 'should set flash success' do
              subject
              expect(flash[:success]).to eq "Tax Category \"#{tax_category.name}\" has been successfully removed!"
            end

            it 'should redirect to the index page' do
              expect(subject).to redirect_to [:admin, :tax_categories]
            end
          end

          context 'when format is js' do
            let(:format) { :js }

            it 'render the destroy template' do
              expect(subject).to render_template('spree/admin/shared/_destroy')
            end
          end
        end

        context 'when destroy is not successful' do
          before do
            allow_any_instance_of(Spree::TaxCategory).to receive(:destroy).and_return false
          end

          it 'should not set a flash success message' do
            subject
            expect(flash[:success]).to be_nil
          end

          it 'should do redirect to the index page' do
            expect(subject).to redirect_to [:admin, :tax_categories]
          end
        end
      end

      describe 'GET #index' do
        subject { spree_get :index }

        it 'should be successful' do
          expect(subject).to be_success
        end
      end

      describe 'PUT #update' do
        let(:tax_category) { create :tax_category }

        subject { spree_put :update, {id: tax_category.id, tax_category: { name: 'Foo', tax_code: 'Bar' }}}

        it 'should redirect' do
          expect(subject).to be_redirect
        end

        it 'should update' do
          subject
          tax_category.reload
          expect(tax_category.name).to eq('Foo')
          expect(tax_category.tax_code).to eq('Bar')
        end
      end
    end
  end
end
