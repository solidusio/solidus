module CapybaraExt
  def page!
  end

  def click_icon(type)
    find(".fa-#{type}").click
  end

  def eventually_fill_in(field, options = {})
    expect(page).to have_css('#' + field)
    fill_in field, options
  end

  def within_row(num, &block)
    within("table.index tbody tr:nth-of-type(#{num})", &block)
  end

  def column_text(num)
    find("td:nth-of-type(#{num})").text
  end

  def fill_in_quantity(table_column, selector, quantity)
    within(table_column) do
      fill_in selector, with: quantity
    end
  end

  def select2_search(value, options)
    options = {
      search: value, # by default search for the value
      select: true
    }.merge(options)
    label = find_label_by_text(options[:from])
    select2 = find_sibling_select2(label)
    select2.click
    select2_enter_search(options[:search])
    select_select2_result(value) if options[:select]
  end

  def find_sibling_select2(element)
    element.first(:xpath, ".//..").find('.select2-container:not(.select2-container--disabled)')
  end

  def select2_enter_search(value)
    within_entire_page do
      find(".select2-container--open .select2-search__field").set(value)
    end
  end

  def select2_search_without_selection(value, options)
    original_select = find(options[:from], visible: false)
    select2 = find_sibling_select2(original_select)
    select2.click
    select2_enter_search(value)
  end

  def targetted_select2_search(value, options)
    select2_search_without_selection(value, from: options[:from])
    select_select2_result(value)
  end

  # Executes the given block within the context of the entire capybara
  # document. Can be used to 'escape' from within the context of another within
  # block.
  def within_entire_page(&block)
    within(:xpath, '//body', &block)
  end

  def select2(value, options)
    label = find_label_by_text(options[:from])

    within label.first(:xpath, ".//..") do
      find('.select2-container').click
    end
    select_select2_result(value)
  end

  def select2_no_label(value, options = {})
    raise "Must pass a hash containing 'from'" if !options.is_a?(Hash) || !options.key?(:from)

    placeholder = options[:from]

    click_link placeholder

    select_select2_result(value)
  end

  def targetted_select2(value, options)
    # find select2 element and click it
    find(options[:from]).find('a').click
    select_select2_result(value)
  end

  def select_select2_result(value)
    # results are in a div appended to the end of the document
    within_entire_page do
      page.find(".select2-results__option", text: /#{Regexp.escape(value)}/i, match: :prefer_exact).click
    end
  end

  def find_label_by_text(text)
    # This used to find the label by it's text using an xpath query, so we use
    # a case insensitive search to avoid breakage with existing usage.
    # We need to select labels which are not .select2-offscreen, as select2
    # makes a duplicate label with the same text, and we want to be sure to
    # find the original.
    find('label:not(.select2-offscreen)', text: /#{Regexp.escape(text)}/i, match: :one)
  end

  def wait_for_ajax
    counter = 0
    while page.evaluate_script("typeof($) === 'undefined' || $.active > 0")
      counter += 1
      sleep(0.1)
      raise "AJAX request took longer than 5 seconds." if counter >= 50
    end
  end

  def accept_alert
    page.evaluate_script('window.confirm = function() { return true; }')
    yield
  end

  def dismiss_alert
    page.evaluate_script('window.confirm = function() { return false; }')
    yield
    # Restore existing default
    page.evaluate_script('window.confirm = function() { return true; }')
  end
end

RSpec::Matchers.define :have_meta do |name, expected|
  match do |_actual|
    has_css?("meta[name='#{name}'][content='#{expected}']", visible: false)
  end

  failure_message do |actual|
    actual = first("meta[name='#{name}']")
    if actual
      "expected that meta #{name} would have content='#{expected}' but was '#{actual[:content]}'"
    else
      "expected that meta #{name} would exist with content='#{expected}'"
    end
  end
end

RSpec.configure do |c|
  c.include CapybaraExt
end
