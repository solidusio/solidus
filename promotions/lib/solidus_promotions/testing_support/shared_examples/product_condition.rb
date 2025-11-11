# frozen_string_literal: true

RSpec.shared_examples "a product condition" do
  let(:condition) do
    super()
  rescue NoMethodError
    described_class.new
  end

  it { is_expected.to have_many :products }

  describe "#product_ids_string" do
    it "returns a string of product ids" do
      condition.products = [create(:product), create(:product)]
      expect(condition.product_ids_string).to eq("#{condition.products[0].id},#{condition.products[1].id}")
    end
  end

  describe "#preload_relations" do
    subject { condition.preload_relations }
    it { is_expected.to eq([:products]) }
  end

  describe "#product_ids_string=" do
    it "sets products based on a string of product ids" do
      product_one = create(:product)
      product_two = create(:product)
      condition.product_ids_string = "#{product_one.id},#{product_two.id}"
      expect(condition.products).to eq([product_one, product_two])
    end
  end

  describe "#preload_relations" do
    subject { condition.preload_relations }
    it { is_expected.to eq([:products]) }
  end
end
