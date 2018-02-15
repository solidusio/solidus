require 'spec_helper'

RSpec.describe SolidusI18n::LocaleHelper do
  describe '#all_locales_options' do
    subject { all_locales_options }

    it 'includes en' do
      is_expected.to include(["English (US)", :en])
    end

    it 'includes ja' do
      is_expected.to include(["日本語 (ja-JP)", :ja])
    end

    describe 'locales' do
      subject { all_locales_options.map(&:last) }

      it 'includes each locale only once' do
        is_expected.to match_array(subject.uniq)
      end

      it 'should match Locale.all' do
        is_expected.to match_array SolidusI18n::Locale.all
      end
    end

    describe 'locale presentation' do
      subject { all_locales_options.map(&:first) }

      it 'should all be unique' do
        is_expected.to match_array(subject.uniq)
      end
    end
  end
end
