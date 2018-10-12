# frozen_string_literal: true

module FillInWithForce
  def fill_in_with_force(locator, with:)
    field_id = find_field(locator)[:id]
    page.execute_script "document.getElementById('#{field_id}').value = '#{with}';"
  end
end

RSpec.configure do |config|
  config.include FillInWithForce, type: :feature
end
