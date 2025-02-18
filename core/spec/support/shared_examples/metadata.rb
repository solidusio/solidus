# frozen_string_literal: true

RSpec.shared_examples "customer and admin metadata fields: storage and validation" do |metadata_class|
  let(:object) { build(metadata_class) }

  it "responds to customer_metadata" do
    expect(object).to respond_to(:customer_metadata)
  end

  it "responds to admin_metadata" do
    expect(object).to respond_to(:admin_metadata)
  end

  it "can store data in customer_metadata" do
    object.customer_metadata = {"order_id" => "OD34236"}
    expect(object.customer_metadata["order_id"]).to eq("OD34236")
  end

  it "can store data in admin_metadata" do
    object.admin_metadata = {"internal_note" => "Generate invoice after payment is received"}
    expect(object.admin_metadata["internal_note"]).to eq("Generate invoice after payment is received")
  end

  let(:invalid_metadata_keys) do
    {
      "company_name" => "demo company",
      "warehouse_name" => "warehouse",
      "serial_number" => "SN-4567890",
      "manufactured_at" => "head office",
      "under_warranty" => "true",
      "delivered_by" => "FedEx",
      "product_type" => "fragile" # Exceeds 6 keys
    }
  end

  let(:valid_metadata_keys) do
    {
      "company_name" => "demo company",
      "warehouse_name" => "warehouse",
      "serial_number" => "SN-4567890",
      "manufactured_at" => "head office",
      "under_warranty" => "true",
      "delivered_by" => "FedEx"
    }
  end

  let(:oversized_value_metadata) { {"product_details" => "This is an amazing product built to last long" * 10} } # Exceeds 256 characters
  let(:valid_value_metadata) { {"product_details" => "This is an amazing product built to last long"} }
  let(:oversized_key_metadata) { {"company_details_for_products" => "This is made by demo company"} } #  Exceeds 16 characters
  let(:valid_key_metadata) { {"company_details" => "This is made by demo company"} }

  subject { create(metadata_class) }

  %w[customer_metadata admin_metadata].each do |metadata_type|
    describe metadata_type do
      context "when metadata validation is enabled" do
        before do
          stub_spree_preferences(meta_data_validation_enabled: true)
        end

        it "does not allow more than 6 keys" do
          subject.send(:"#{metadata_type}=", invalid_metadata_keys)

          expect(subject).not_to be_valid
          expect(subject.errors[metadata_type.to_sym]).to include("must not have more than 6 keys")
        end

        it "allows less than 6 keys" do
          subject.send(:"#{metadata_type}=", valid_metadata_keys)

          expect(subject).to be_valid
        end

        it "does not allow values longer than 256 characters" do
          subject.send(:"#{metadata_type}=", oversized_value_metadata)

          expect(subject).not_to be_valid
          expect(subject.errors[metadata_type.to_sym]).to include("value for key 'product_details' exceeds 256 characters")
        end

        it "allows values shorter than 256 characters" do
          subject.send(:"#{metadata_type}=", valid_value_metadata)

          expect(subject).to be_valid
        end

        it "does not allow keys longer than 16 characters" do
          subject.send(:"#{metadata_type}=", oversized_key_metadata)

          expect(subject).not_to be_valid
          expect(subject.errors[metadata_type.to_sym]).to include("key 'company_details_for_products' exceeds 16 characters")
        end

        it "allows keys shorter than 16 characters" do
          subject.send(:"#{metadata_type}=", valid_key_metadata)

          expect(subject).to be_valid
        end
      end

      context "when metadata validation is disabled" do
        before do
          stub_spree_preferences(meta_data_validation_enabled: false)
        end

        it "does not validate the metadata" do
          subject.send(:"#{metadata_type}=", invalid_metadata_keys)

          expect(subject).to be_valid
        end

        it "allows more than 6 keys" do
          subject.send(:"#{metadata_type}=", invalid_metadata_keys)

          expect(subject).to be_valid
        end

        it "allows values longer than 256 characters" do
          subject.send(:"#{metadata_type}=", oversized_value_metadata)

          expect(subject).to be_valid
        end

        it "allows keys longer than 16 characters" do
          subject.send(:"#{metadata_type}=", oversized_key_metadata)

          expect(subject).to be_valid
        end
      end
    end
  end
end
