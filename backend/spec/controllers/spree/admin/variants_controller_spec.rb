require 'spec_helper'

module Spree
  module Admin
    describe VariantsController, type: :controller do
      stub_authorization!

      describe "#index" do
        let(:product) { create(:product) }
        let(:params) { { product_id: product.slug } }

        subject { get :index, params: params }

        context "the value of @parent" do
          it "is the product" do
            subject
            expect(assigns(:parent)).to eq product
          end

          context "with a deleted product" do
            before { product.destroy! }

            it "is the product" do
              subject
              expect(assigns(:parent)).to eq product
            end
          end
        end

        context "assigning @collection" do
          let!(:variant) { create(:variant, product: product) }
          let!(:deleted_variant) { create(:variant, product: product) }

          context "with deleted variants" do
            before { deleted_variant.destroy }

            context "deleted is not requested" do
              it "does not assign deleted variants for a requested product" do
                subject
                expect(assigns(:collection)).to include variant
                expect(assigns(:collection)).not_to include deleted_variant
              end
            end

            context "deleted is requested" do
              let(:params) { { product_id: product.slug, deleted: "on" } }

              it "assigns deleted along with non-deleted variants for a requested product" do
                subject
                expect(assigns(:collection)).to include variant
                expect(assigns(:collection)).to include deleted_variant
              end
            end
          end
        end
      end
    end
  end
end
