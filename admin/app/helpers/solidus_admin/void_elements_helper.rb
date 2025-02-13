# frozen_string_literal: true

module SolidusAdmin
  module VoidElementsHelper
    # https://github.com/rails/rails/blob/194d697036c61af0caa66de5659721ded2478ce9/actionview/lib/action_view/helpers/tag_helper.rb#L84
    HTML_VOID_ELEMENTS = %i(area base br col embed hr img input keygen link meta source track wbr)

    # @param el [Symbol]
    def void_element?(el)
      HTML_VOID_ELEMENTS.include?(el)
    end
  end
end
