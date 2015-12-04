require 'spec_helper'

describe Spree::Admin::VariantImageRulesController, type: :controller do
  stub_authorization!

  let(:option_value) { create(:option_value) }
  let(:image_path) { File.expand_path('../../../../fixtures/thinking-cat.jpg', __FILE__) }
  let!(:product) { create(:product, option_types: [option_value.option_type]) }

  describe "#create" do
    let(:payload) do
      {
        product_id: product.to_param,
        variant_image_rule: {
          option_value_ids: option_value.id,
          values_attributes: {
            "0" => {
              image_attachment: fixture_file_upload(image_path, 'image/jpeg'),
              image_alt: "New test image"
            }
          }
        }
      }
    end

    subject { spree_post :create, payload }

    context "successful create" do
      it "creates a new rule" do
        expect { subject }.to change { Spree::VariantImageRule.count }.by(1)
      end

      it "creates a rule condition" do
        expect { subject }.to change { Spree::VariantImageRuleCondition.count }.by(1)
      end

      it "creates an image" do
        subject
        expect(Spree::Image.find_by(alt: "New test image")).to_not be_nil
      end

      it "redirects to the variant image rules page" do
        subject
        expect(response).to redirect_to(spree.admin_product_variant_image_rules_path(product, ovi: [option_value.id]))
      end
    end

    context "unsuccessful create" do
      before do
        allow_any_instance_of(Spree::VariantImageRule).to receive(:save).and_return(false)
        allow_any_instance_of(Spree::VariantImageRule).to receive_message_chain("errors.empty?") { false }
        allow_any_instance_of(Spree::VariantImageRule).to receive_message_chain("errors.full_messages") { ["Unsuccessful test create"] }
      end

      it "doesn't create a new rule" do
        expect { subject }.to_not change { Spree::VariantImageRule.count }
      end

      it "doesn't create a new image" do
        expect { subject }.to_not change { Spree::Image.count }
      end

      it "renders the index page" do
        subject
        expect(response).to render_template(:index)
      end

      it "adds an error to the flash" do
        subject
        expect(flash[:error]).to eq "Unsuccessful test create"
      end
    end
  end

  describe "#update" do
    let(:original_option_value) { create(:option_value) }
    let!(:rule) do
      create(:variant_image_rule, product: product, option_value: original_option_value)
    end
    let(:payload) do
      {
        id: rule.id,
        product_id: product.to_param,
        variant_image_rule: {
          option_value_ids: option_value.id,
          values_attributes: {
            "0" => {
              image_attachment: fixture_file_upload(image_path, 'image/jpeg'),
              image_alt: "New test image"
            }
          }
        }
      }
    end

    subject { spree_put :update, payload }

    context "successful update" do
      it "does not create any new rules" do
        expect { subject }.to_not change { Spree::VariantImageRule.count }
      end

      it "replaces the rule's condition" do
        expect { subject }.to change { rule.option_value_ids }.from([original_option_value.id]).to([option_value.id])
      end

      it "adds the image to the rule" do
        expect { subject }.to change { rule.values.count }.by(1)
      end

      it "creates the image" do
        subject
        expect(rule.images.where(alt: "New test image")).to_not be_nil
      end

      it "redirects to the variant image rules page" do
        subject
        expect(response).to redirect_to(spree.admin_product_variant_image_rules_path(product, ovi: [option_value.id]))
      end
    end

    context "unsuccessful update" do
      before do
        allow_any_instance_of(Spree::VariantImageRule).to receive(:update_attributes).and_return(false)
        allow_any_instance_of(Spree::VariantImageRule).to receive_message_chain("errors.empty?") { false }
        allow_any_instance_of(Spree::VariantImageRule).to receive_message_chain("errors.full_messages") { ["Unsuccessful test update"] }
      end

      it "renders the index page" do
        subject
        expect(response).to render_template(:index)
      end

      it "doesn't create a new image" do
        expect { subject }.to_not change { Spree::Image.count }
      end

      it "adds an error to the flash" do
        subject
        expect(flash[:error]).to eq "Unsuccessful test update"
      end
    end
  end
end
