require "rails_helper"

RSpec.describe Spree::MigrationHelpers do
  let(:helper) do
    double.as_null_object.tap do |object|
      object.extend(described_class)
      object.extend(ActiveRecord::ConnectionAdapters::SchemaStatements)
    end
  end

  subject { helper.safe_add_index(double, double) }

  # regression test
  describe "#safe_add_index" do
    context "when the column exists" do
      context "and the index does" do
        it "passes compatible arguments to index_exists?" do
          expect { subject }.to_not raise_error(ArgumentError)
        end
      end

      context "and the index does not" do
        before do
          allow(helper).to receive(:index_exists?).with(any_args).and_return(false)
        end

        it "passes compatible arguments to add_index" do
          expect { subject }.to_not raise_error(ArgumentError)
        end
      end
    end
  end
end
