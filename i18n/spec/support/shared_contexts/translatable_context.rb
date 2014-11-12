shared_context "behaves as translatable" do
  testable_attributes = [:name, :value]
  attribute = nil

  before do
    subject.attribute_names.each do |a|
      if testable_attributes.include? a.to_sym
        attribute = a.to_sym
      end
    end
  end

  context "when there's a missing translation" do
    before do
      subject[attribute] = "English"
      I18n.locale = :es
    end

    it "falls back to default locale" do
      expect(subject[attribute]).to eq "English"
    end
  end

  context "missing translation on default locale" do
    let!(:change_locale) { I18n.locale = :es }
    let!(:model) { subject.class.new }

    before do
      SpreeI18n::Config.supported_locales = [:en, :es, :de]
      SpreeI18n::Fallbacks.config!

      model[attribute] = 'produto'
    end

    it "falls back to not default translations" do
      I18n.locale = :en
      expect(model[attribute]).to eq "produto"
    end
  end

  context "missing translation on locale other than default" do
    let!(:model) { subject.class.new }

    before do
      SpreeI18n::Config.supported_locales = [:es, :en, :de]
      SpreeI18n::Fallbacks.config!

      model[attribute] = 'product'
    end

    it "falls back to default locale first" do
      I18n.locale = :es
      model[attribute] = "produto"

      I18n.locale = :de
      expect(model[attribute]).to eq "product"
    end
  end
end
