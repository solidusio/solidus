# frozen_string_literal: true

# Middleman - Inline SVG Helper
# ------------------------------------------------------------------------------
# https://gist.github.com/bitmanic/0047ef8d7eaec0bf31bb
#
# Embed SVG files into your template files like so:
#
#    <%= inline_svg("path/to/image.svg"); %> assuming image.svg is stored at source/assets/images/
#
#    The helper also allows for CSS classes to be added:
#
#      <%= inline_svg("name/of/file.svg", class: "my-addl-class") %>
#
# /image_helpers.rb
module ImageHelpers
  def inline_svg(filename, options = {})
    asset = "source/assets/images/#{filename}"

    if File.exist?(asset)
      file = File.open(asset, 'r') { |file_io| file_io.read }
      # we pass svg-targeting css classes through here, ex. .svg-color--blue. The class targets fill, stroke, poly, circle, etc.
      css_class = options[:class]
      # this could be passed via helper, right now this default covers most of our svg use cases.
      radio_default = "xMidYMid meet"
      return file if css_class.nil?

      document = Oga.parse_xml(file)
      svg      = document.css('svg').first

      svg.set(:class, css_class)
      svg.set(:preserveAspectRatio, radio_default)

      document.to_xml
    else
      puts "inline_svg '#{asset}' at #{current_page.url} could not be found!"
      %(
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 60"
          width="400px" height="60px"
        >
          <text font-size="12" x="8" y="20" fill="#cc0000">
            Error: '#{asset}' could not be found.
          </text>
          <rect
            x="1" y="1" width="398" height="38" fill="none"
            stroke-width="1" stroke="#cc0000"
          />
        </svg>
      )
    end
  end
end
