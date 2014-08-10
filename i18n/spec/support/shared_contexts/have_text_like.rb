RSpec::Matchers.define :have_text_like do |expected|
  match { have_text(/#{expected}/iu) }

  failure_message do
    "expected that text would exist with '#{expected}'"
  end
end
