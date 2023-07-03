# frozen_string_literal: true

require 'spec_helper'
require 'generators/solidus_admin/component/component_generator'

RSpec.describe SolidusAdmin::ComponentGenerator, type: :generator do
  it "creates a component with the given name" do
    run_generator %w[ui/foo]

    aggregate_failures do
      expect(engine_path('app/components/solidus_admin/ui/foo/component.rb').read).to include('class SolidusAdmin::UI::Foo::Component <')
      expect(engine_path('app/components/solidus_admin/ui/foo/component.yml').read).to match(/^en:$/)
      expect(engine_path('app/components/solidus_admin/ui/foo/component.html.erb').read).to start_with(%{<div class="<%= stimulus_id %>"})
      expect(engine_path('app/components/solidus_admin/ui/foo/component.js').read).to include(%{export default class extends Controller})
      expect(engine_path('spec/components/solidus_admin/ui/foo/component_spec.rb').read).to include(%{RSpec.describe SolidusAdmin::UI::Foo::Component})
    end
  end

  private

  def engine_path(path)
    pathname = Pathname(destination_root).join(path)
    block_given? ? yield(pathname) : pathname
  end
end
