# frozen_string_literal: true

require "i18n/tasks"

RSpec.describe "solidus_i18n translations" do
  let(:i18n) { I18n::Tasks::BaseTask.new }

  it "uses the same interpolations as solidus_core's en.yml" do
    inconsistent = i18n.inconsistent_interpolations
    error_message = "#{inconsistent.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Run `i18n-tasks check-consistent-interpolations' in i18n/ to show them"
    expect(inconsistent).to be_empty, error_message
  end
end
