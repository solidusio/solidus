require 'rspec/expectations'
require 'solidus/i18n'
require 'solidus/testing_support/i18n'

describe "i18n" do
  before do
    I18n.backend.store_translations(:en,
    {
      :spree => {
        :foo => "bar",
        :bar => {
          :foo => "bar within bar scope",
          :invalid => nil,
          :legacy_translation => "back in the day..."
        },
        :invalid => nil,
        :legacy_translation => "back in the day..."
      }
    })
  end

  it "translates within the spree scope" do
    expect(Solidus.normal_t(:foo)).to eql("bar")
    expect(Solidus.translate(:foo)).to eql("bar")
  end

  it "prepends a string scope" do
    expect(Solidus.normal_t(:foo, :scope => "bar")).to eql("bar within bar scope")
  end

  it "prepends to an array scope" do
    expect(Solidus.normal_t(:foo, :scope => ["bar"])).to eql("bar within bar scope")
  end

  it "returns two translations" do
    expect(Solidus.normal_t([:foo, 'bar.foo'])).to eql(["bar", "bar within bar scope"])
  end

  it "returns reasonable string for missing translations" do
    expect(Solidus.t(:missing_entry)).to include("<span")
  end

  context "missed + unused translations" do
    def key_with_locale(key)
      "#{key} (#{I18n.locale})"
    end

    before do
      Solidus.used_translations = []
    end

    context "missed translations" do
      def assert_missing_translation(key)
        key = key_with_locale(key)
        message = Solidus.missing_translation_messages.detect { |m| m == key }
        expect(message).not_to(be_nil, "expected '#{key}' to be missing, but it wasn't.")
      end

      it "logs missing translations" do
        Solidus.t(:missing, :scope => [:else, :where])
        Solidus.check_missing_translations
        assert_missing_translation("else")
        assert_missing_translation("else.where")
        assert_missing_translation("else.where.missing")
      end

      it "does not log present translations" do
        Solidus.t(:foo)
        Solidus.check_missing_translations
        expect(Solidus.missing_translation_messages).to be_empty
      end

      it "does not break when asked for multiple translations" do
        Solidus.t [:foo, 'bar.foo']
        Solidus.check_missing_translations
        expect(Solidus.missing_translation_messages).to be_empty
      end
    end

    context "unused translations" do
      def assert_unused_translation(key)
        key = key_with_locale(key)
        message = Solidus.unused_translation_messages.detect { |m| m == key }
        expect(message).not_to(be_nil, "expected '#{key}' to be unused, but it was used.")
      end

      def assert_used_translation(key)
        key = key_with_locale(key)
        message = Solidus.unused_translation_messages.detect { |m| m == key }
        expect(message).to(be_nil, "expected '#{key}' to be used, but it wasn't.")
      end

      it "logs translations that aren't used" do
        Solidus.check_unused_translations
        assert_unused_translation("bar.legacy_translation")
        assert_unused_translation("legacy_translation")
      end

      it "does not log used translations" do
        Solidus.t(:foo)
        Solidus.check_unused_translations
        assert_used_translation("foo")
      end
    end
  end
end
