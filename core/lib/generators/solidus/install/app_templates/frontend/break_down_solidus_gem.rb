# # This will unpack the solidus gem into its components without calling `bundle install`.
#
# # Nothing to do if the `solidus` gem is not there.
solidus = Bundler.locked_gems.dependencies['solidus'] or return

# Write and remove into and from a Gemfile
#
# This custom injector fixes support for path, git and custom sources,
# which is missing in bundler's upstream injector for a dependency fetched
# with `Bundler.locked_gems.dependencies`.
bundler_injector = Class.new(Bundler::Injector) do
  def build_gem_lines(conservative_versioning)
    @deps.map do |d|
      name = d.name.dump
      is_local = d.source.instance_of?(Bundler::Source::Path)
      is_git = d.source.instance_of?(Bundler::Source::Git)

      requirement = if is_local
                      ", path: \"#{d.source.path}\""
                    elsif is_git
                      ", git: \"#{d.git}\"".yield_self { |g| d.ref ? g + ", ref: \"#{d.ref}\"" : g }
                    elsif conservative_versioning
                      ", \"#{conservative_version(@definition.specs[d.name][0])}\""
                    else
                      ", #{d.requirement.as_list.map(&:dump).join(", ")}"
                    end

      source = ", source: \"#{d.source.remotes.join(",")}\"" unless is_local || is_git || d.source.nil?

      %(gem #{name}#{requirement}#{source})
    end.join("\n")
  end
end

to_dependency = ->(component) do
  Bundler::Dependency.new(
    component,
    solidus.requirement,
    "source" => solidus.source,
    "git" => solidus.source.try(:uri),
    "ref" => solidus.source.try(:ref),
  )
end

bundler_injector.inject(%w[
  solidus_core
  solidus_backend
  solidus_api
  solidus_sample
].map(&to_dependency))

bundler_injector.remove(%w[
  solidus
])

