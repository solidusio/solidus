# frozen_string_literal: true

RSpec.shared_examples_for "a promotion calculator" do
  describe ".description" do
    subject { described_class.description }

    it "has a description" do
      expect(subject.size).to be > 0
    end
  end
end
