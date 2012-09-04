require 'spec_helper'

describe "locale files" do
  Dir.glob('config/locales/*.yml') do |locale_file|
    describe "a locale file" do
      it_behaves_like 'a valid locale file', locale_file
    end
  end
end
