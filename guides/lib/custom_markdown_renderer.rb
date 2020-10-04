# frozen_string_literal: true

class CustomMarkdownRenderer < Redcarpet::Render::HTML
  include ImageHelpers
  include ::Padrino::Helpers::OutputHelpers
  include ::Padrino::Helpers::TagHelpers

  def block_code(code, language)
    path = code.lines.first[/^#\s(\S*)$/, 1]
    code = code.lines[1..-1].join if path
    code = code.gsub('<', '&lt').gsub('>', '&gt')
    template = File.read('source/partials/_code_block.erb')
    ERB.new(template).result(binding)
  end

  def table(header, body)
    header_labels = header.scan(/<th>([\s\S]*?)<\/th>/).flatten
    table_rows = parse_table(body)
    template = File.read('source/partials/_table.erb')
    ERB.new(template).result(binding)
  end

  def header(text, header_level)
    content_tag "h#{header_level}", id: text.parameterize, class: 'offset' do
      mark_safe(text)
    end
  end

  def link(link, title, content)
    template = File.read('source/partials/_anchor.erb')
    ERB.new(template).result(binding)
  end

  private

  # This function takes an HTML string and parses it into a nested list. The
  # outer list represents table rows, while the inner lists represent the table
  # data itself.
  def parse_table(table_body)
    [].tap do |table_rows|
      table_body.scan(/<tr>([\s\S]*?)<\/tr>/).flatten.each do |tr_inner_markup|
        tds = []
        tr_inner_markup.scan(/<td>([\s\S]*?)<\/td>/).flatten.each do |td_inner_markup|
          tds << td_inner_markup
        end
        table_rows << tds
      end
    end
  end
end
