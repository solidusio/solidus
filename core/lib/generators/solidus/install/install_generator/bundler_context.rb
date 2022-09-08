# frozen_string_literal: true

module Solidus
  class InstallGenerator < Rails::Generators::Base
    # Bundler context during the install process.
    #
    # This class gives access to information about the bundler context in which
    # the install generator is run. I.e., which solidus components are present
    # in the user's Gemfile. It also allows modifying the Gemfile to add or
    # remove gems.
    #
    # @api private
    class BundlerContext
      # Write and remove into and from a Gemfile
      #
      # This custom injector fixes support for path, git and custom sources,
      # which is missing in bundler's upstream injector for a dependency fetched
      # with `Bundled.locked_gems.dependencies`.
      #
      # @api private
      class InjectorWithPathSupport < Bundler::Injector
        private def build_gem_lines(conservative_versioning)
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

            source = ", :source => \"#{d.source.remotes.join(",")}\"" unless is_local || is_git || d.source.nil?

            %(gem #{name}#{requirement}#{source})
          end.join("\n")
        end
      end

      attr_reader :dependencies, :injector

      def self.bundle_cleanly(&block)
        Bundler.respond_to?(:with_unbundled_env) ? Bundler.with_unbundled_env(&block) : Bundler.with_clean_env(&block)
      end

      def initialize
        @dependencies = Bundler.locked_gems.dependencies
        @injector = InjectorWithPathSupport
      end

      def solidus_in_gemfile?
        !solidus_dependency.nil?
      end

      def component_in_gemfile?(name)
        !@dependencies["solidus_#{name}"].nil?
      end

      def break_down_components(components)
        unless solidus_in_gemfile?
          raise "solidus meta gem needs to be present in the Gemfile to build the component dependency"
        end

        @injector.inject(
          components.map { |component| dependency_for_component(component) }
        )
      end

      def remove(*args, **kwargs, &block)
        @injector.remove(*args, **kwargs, &block)
      end

      private

      def dependency_for_component(component)
        Bundler::Dependency.new(
          "solidus_#{component}",
          solidus_dependency.requirement,
          {
            "source" => solidus_dependency.source,
            "git" => solidus_dependency.source.try(:uri),
            "ref" => solidus_dependency.source.try(:ref)
          }
        )
      end

      def solidus_dependency
        @dependencies['solidus']
      end
    end
  end
end
