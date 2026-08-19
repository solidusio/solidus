# frozen_string_literal: true

require "spec_helper"

# Some code paths are guarded with `defined?` so that solidus_admin can be
# released ahead of solidus_core. These specs fail once the gemspec stops
# supporting the versions that made a guard necessary, so that the guard is
# removed together with the version bump instead of lingering as dead code.
RSpec.describe "solidus_core compatibility guards" do
  let(:solidus_core_requirement) do
    gemspec = Gem::Specification.load(
      SolidusAdmin::Engine.root.join("solidus_admin.gemspec").to_s
    )
    gemspec.dependencies.find { _1.name == "solidus_core" }.requirement
  end

  describe "Spree::Core::ControllerHelpers::Timezone" do
    it "is still guarded, because solidus_core 4.7 does not provide it" do
      expect(solidus_core_requirement).to be_satisfied_by(Gem::Version.new("4.7.0")),
        "solidus_core 4.7 is no longer supported, so the Timezone helper is always " \
        "available. Remove the `defined?(Spree::Core::ControllerHelpers::Timezone)` " \
        "guards from app/controllers/solidus_admin/base_controller.rb and " \
        "app/components/solidus_admin/layout/navigation/account/component.html.erb, " \
        "along with the specs covering the unguarded path."
    end
  end
end
