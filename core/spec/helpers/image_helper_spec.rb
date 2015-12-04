require 'spec_helper'

module Spree
  describe ImageHelper, type: :helper do
    include ImageHelper

    describe "#image_dom_id" do

      subject { helper.image_dom_id(image) }

      context "viewable is a product" do
        let(:product) { create(:product) }
        let(:image) { create(:image, viewable: product) }

        it { is_expected.to eq("#{product.id}") }
      end

      context "viewable is a variant" do
        let(:variant) { create(:variant) }
        let(:image) { create(:image, viewable: variant) }

        it { is_expected.to eq("#{variant.id}") }
      end

      context "viewable is a variant image rule" do
        let(:image) { create(:image) }
        let(:option_value_1) { create(:option_value) }
        let(:option_value_2) { create(:option_value) }
        let(:shared_option_value) { create(:option_value) }
        let(:product) { create(:product) }
        let!(:variant_1) { create(:variant, product: product, option_values: [shared_option_value, option_value_1])}
        let!(:variant_2) { create(:variant, product: product, option_values: [shared_option_value, option_value_2])}
        let!(:rule_image) { create(:variant_image_rule, product: product, option_value: shared_option_value, image: image) }

        it { is_expected.to eq("#{variant_1.id},#{variant_2.id}") }
      end

      context "viewable is not supported" do
        let(:promotion) { create(:promotion) }
        let(:image) { create(:image, viewable: promotion) }

        it "raises an error" do
          expect { subject }.to raise_error("Unexpected viewable type")
        end
      end
    end
  end
end
