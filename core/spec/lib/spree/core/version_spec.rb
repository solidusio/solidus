describe Spree do
  describe '.solidus_version' do
    it "returns a string" do
      expect(Spree.solidus_version).to be_a(String)
    end
  end
end
