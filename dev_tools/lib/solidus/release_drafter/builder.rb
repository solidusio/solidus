# frozen_string_literal: true

require 'set'

module Solidus
  class ReleaseDrafter
    # Defines the template for releases and adds entries to it.
    #
    # @api private
    class Builder
      TITLE_PREFIX = '## '

      TITLE_TEMPLATE = lambda do |category|
        TITLE_PREFIX + category
      end.freeze

      SEPARATOR = "\n"

      TITLE_SEPARATOR = SEPARATOR

      ENTRY_TEMPLATE = lambda do |title, number, user|
        "- #{title} ##{number} (@#{user})"
      end.freeze

      ENTRY_SEPARATOR = SEPARATOR

      SECTION_SEPARATOR = SEPARATOR + SEPARATOR

      def initialize(draft:, categories:, prepend: '', append: '')
        @categories = Set[*categories]
        @prepend = prepend
        @prepend_pattern = /^#{Regexp.quote(@prepend)}/m
        @append = append
        @append_pattern = /#{Regexp.quote(@append)}$/m
        @draft = draft.new? ? draft.with(content: initial_content) : draft
        sanitize_prepend_append
        @ast = build_ast
        sanitize_categories
      end

      def add(title:, number:, user:, categories:)
        ENTRY_TEMPLATE.(title, number, user)
          .then { |entry| add_to_ast(entry, categories) }
          .then { |ast| @draft.with(content: unparse(ast)) }
      end

      private

      def initial_content
        @prepend + @categories.map do |category|
          TITLE_TEMPLATE.(category)
        end.join(SECTION_SEPARATOR) + @append
      end

      def build_ast
        generated_lines.reduce([nil, {}]) do |(current_category, ast), line|
          maybe_next_category = line.match(/^#{TITLE_PREFIX}(.*)$/)&.[](1)
          if line.strip.empty?
            [current_category, ast]
          elsif maybe_next_category
            [maybe_next_category, ast.merge(maybe_next_category => [])]
          elsif current_category
            [current_category, ast.merge(current_category => ast[current_category] + [line])]
          else
            [current_category, ast]
          end
        end[1]
      end

      def add_to_ast(entry, categories)
        (@categories & categories).each_with_object(@ast.dup) do |category, ast|
          ast[category] << entry
        end
      end

      def unparse(ast)
        @prepend + ast.map do |(category, entries)|
          "#{TITLE_TEMPLATE.(category)}#{TITLE_SEPARATOR}#{entries.join(ENTRY_SEPARATOR)}"
        end.join(SECTION_SEPARATOR) + @append
      end

      def generated_lines
        @draft
          .content
          .gsub(@prepend_pattern, '')
          .gsub(@append_pattern, '')
          .lines(SEPARATOR, chomp: true)
      end

      def sanitize_prepend_append
        raise <<~MSG unless @draft.content.match(@prepend_pattern)
          Prepended text is not present in the draft.

          We expected to find

          ---
          #{@prepend}
          ---

          at the beginning of

          ---
          #{@draft.content}
          ---
        MSG

        raise <<~MSG unless @draft.content.match(@append_pattern)
          Appended text is not present in the draft.

          We expected to find

          ---
          #{@append}
          ---

          at the end of

          ---
          #{@draft.content}
          ---
        MSG
      end

      def sanitize_categories
        raise <<~MSG unless @categories == Set[*@ast.keys]
          Given categories don't match those found in the draft.

          Given categories:

          #{@categories.join(', ')}

          Found categories:

          #{@ast.keys.join(', ')}
        MSG
      end
    end
  end
end
