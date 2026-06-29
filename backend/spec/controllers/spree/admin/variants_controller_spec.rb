# frozen_string_literal: true

require "spec_helper"

module Spree
  module Admin
    describe VariantsController, type: :controller do
      stub_authorization!

      describe "#new" do
        render_views

        let(:product) { create(:product_with_option_types) }

        before do
          create(:option_value, option_type: product.option_types.first)
        end

        subject { get :new, params: {product_id: product.slug} }

        it "builds a variant with the master default price" do
          subject

          expect(response).to be_successful
          expect(assigns(:variant).default_price.amount).to eq(product.master.default_price.amount)
        end

        context "when the product has no master default price" do
          before do
            product.master.prices.delete_all
          end

          it "builds a variant with a new default price" do
            subject

            default_price = assigns(:variant).default_price

            expect(response).to be_successful
            expect(default_price).to be_new_record
            expect(default_price.amount).to be_nil
            expect(default_price.currency).to eq(Spree::Config[:currency])
          end
        end
      end

      describe "#index" do
        let(:product) { create(:product) }
        let(:params) { {product_id: product.slug} }

        subject { get :index, params: }

        context "the value of @parent" do
          it "is the product" do
            subject
            expect(assigns(:parent)).to eq product
          end

          context "with a deleted product" do
            before { product.discard }

            it "is the product" do
              subject
              expect(assigns(:parent)).to eq product
            end
          end
        end

        context "the value of @collection" do
          let!(:variant) { create(:variant, product:) }
          let!(:deleted_variant) { create(:variant, product:) }

          context "with soft-deleted variants" do
            before { deleted_variant.discard }

            context "when deleted is not requested" do
              it "excludes deleted variants" do
                subject
                expect(assigns(:collection)).to include variant
                expect(assigns(:collection)).not_to include deleted_variant
              end
            end

            context "when deleted is requested" do
              let(:params) { {product_id: product.slug, deleted: "on"} }

              it "includes deleted variants" do
                subject
                expect(assigns(:collection)).to include variant
                expect(assigns(:collection)).to include deleted_variant
              end
            end
            context "existent product id not given" do
              let(:params) { {product_id: "non-existent-product"} }

              it "cannot find non-existent product" do
                subject
                expect(response).to redirect_to(spree.admin_products_path)
                expect(flash[:error]).to eql("Product is not found")
              end
            end
          end
        end
      end

      describe "#delete" do
        let!(:variant) { create(:variant) }
        let(:product) { variant.product }

        it "can be deleted" do
          delete :destroy, params: {product_id: product.to_param, id: variant.to_param}
          expect(variant.reload).to be_discarded
        end
      end
    end
  end
end
