shared_context "behaves as translatable" do
  context "when there's a missing translation" do
    before do
      subject.name = "English"
      I18n.locale = :es
    end

    it "falls back to default locale" do
      subject.name.should == "English"
    end
  end
end
