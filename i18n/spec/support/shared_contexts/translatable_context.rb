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

  context "missing translation on default locale" do
    let!(:change_locale) { I18n.locale = :es }
    let!(:model) { subject.class.new(name: 'produto') }

    before do
      SpreeI18n::Config.supported_locales = [:en, :es, :de]
      SpreeI18n::Fallbacks.config!
    end

    it "falls back to not default translations" do
      I18n.locale = :en
      model.name.should == "produto"
    end
  end

  context "missing translation on locale other than default" do
    let!(:model) { subject.class.new(name: 'product') }

    before do
      SpreeI18n::Config.supported_locales = [:es, :en, :de]
      SpreeI18n::Fallbacks.config!
    end

    it "falls back to default locale first" do
      I18n.locale = :es
      model.name = "produto"

      I18n.locale = :de
      model.name.should == "product"
    end
  end
end
