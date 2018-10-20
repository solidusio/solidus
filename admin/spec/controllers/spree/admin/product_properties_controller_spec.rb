# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Admin
    describe ProductPropertiesController, type: :controller do
      stub_authorization!

      describe "#index" do
        subject { get :index, params: parameters }

        context "no option values are provided" do
          let(:product) { create(:product) }
          let(:parameters) do
            { product_id: product.to_param }
          end

          before { subject }

          it "instantiates a new variant property rule" do
            expect(assigns(:variant_property_rule)).to_not be_persisted
          end

          it "instantiates a new variant property rule value" do
            expect(assigns(:variant_property_rule).values.size).to eq 1
            expect(assigns(:variant_property_rule).values.first).to_not be_persisted
          end
        end

        context "option values are provided" do
          let(:size) { create(:option_type, name: 'size') }
          let(:product) { create(:product, option_types: [size]) }
          let(:size_small) { create(:option_value, name: 'small', option_type: size) }
          let(:size_large) { create(:option_value, name: 'large', option_type: size) }
          let!(:first_rule) { create(:variant_property_rule, product: product, option_value: size_small) }

          context "no rules match the option values" do
            let(:parameters) do
              {
                product_id: product.to_param,
                ovi: [size_large.id]
              }
            end

            before { subject }

            it "instantiates a new variant property rule" do
              expect(assigns(:variant_property_rule)).to_not be_persisted
            end
          end

          context "a rule matches the option values" do
            let(:parameters) do
              {
                product_id: product.to_param,
                ovi: [size_small.id]
              }
            end

            before { subject }

            it "assigns the property rule to the only property rule that matches the option values" do
              expect(assigns(:variant_property_rule)).to eq first_rule
            end
          end
        end
      end
    end
  end
end
