# frozen_string_literal: true

module ImageSpecHelper
  def open_image(image)
    File.open(File.join('lib', 'spree', 'testing_support', 'fixtures', image))
  end
end

