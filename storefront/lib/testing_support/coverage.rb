# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"

  if ENV["COVERAGE_DIR"]
    SimpleCov.coverage_dir(ENV["COVERAGE_DIR"])
  end

  if ENV["GITHUB_ACTIONS"]
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end

  def (SimpleCov::ResultAdapter).call(result)
    result = result.transform_keys do |path|
      template_path = path.sub(
        "#{SimpleCov.root}/",
        "#{SimpleCov.root}/../storefront/templates/"
      )
      File.exist?(template_path) ? template_path : path
    end
    result.each do |path, coverage|
      next unless path.end_with?(".erb")

      # Remove the extra trailing lines added by ERB
      coverage[:lines] = coverage[:lines][...File.read(path).lines.size]
    end
    result
  end

  SimpleCov.command_name("solidus:storefront")
  SimpleCov.merge_timeout(3600)
  SimpleCov.start("rails")
end
