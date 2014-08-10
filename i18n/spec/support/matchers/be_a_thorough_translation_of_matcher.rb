RSpec::Matchers.define :be_a_thorough_translation_of do |default_locale_filepath|
  match do |filepath|
    locale_file = I18nSpec::LocaleFile.new(filepath)
    default_locale = I18nSpec::LocaleFile.new(default_locale_filepath)

    @misses = default_locale.flattened_translations.select do |key, value|
      !@keys.include?(key) &&
        locale_file.flattened_translations[key] != "" &&
        locale_file.flattened_translations[key] == value
    end
    @misses.empty?
  end

  chain :except do |keys|
    @keys = keys
  end

  failure_message do |filepath|
    "expected #{filepath} to translate :\n- " << @misses.keys.sort.join("\n- ")
  end
end
