# frozen_string_literal: true

RSpec.shared_examples "an option value condition" do
  let(:condition) do
    super()
  rescue NoMethodError
    described_class.new
  end

  describe "#preferred_eligible_values" do
    subject { condition.preferred_eligible_values }

    it "assigns a nicely formatted hash" do
      condition.preferred_eligible_values = { "5" => "1,2", "6" => "1" }
      expect(subject).to eq({ 5 => [1, 2], 6 => [1] })
    end
  end
end
