module CapybaraExt
  def page!
    save_and_open_page
  end

  def click_icon(type)
    find(".fa-#{type}").click
  end

  def eventually_fill_in(field, options={})
    expect(page).to have_css('#' + field)
    fill_in field, options
  end

  def within_row(num, &block)
    if RSpec.current_example.metadata[:js]
      within("table.index tbody tr:nth-child(#{num})", &block)
    else
      within(:xpath, all("table.index tbody tr")[num-1].path, &block)
    end
  end

  def column_text(num)
    if RSpec.current_example.metadata[:js]
      find("td:nth-child(#{num})").text
    else
      all("td")[num-1].text
    end
  end

  def fill_in_quantity(table_column, selector, quantity)
    within(table_column) do
      fill_in selector, :with => quantity
    end
  end

  def select2_search(value, options)
    label = find_label_by_text(options[:from])
    within label.first(:xpath,".//..") do
      options[:from] = "##{find(".select2-container")["id"]}"
    end
    targetted_select2_search(value, options)
  end

  def select2_search_without_selection(value, options)
    find("#{options[:from]}:not(.select2-container-disabled)").click

    within_entire_page do
      select2input = first("#select2-drop input.select2-input") || find("input.select2-input")
      select2input.set(value)
    end
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

    within label.first(:xpath,".//..") do
      options[:from] = "##{find(".select2-container")["id"]}"
    end
    targetted_select2(value, options)
  end

  def select2_no_label value, options={}
    raise "Must pass a hash containing 'from'" if not options.is_a?(Hash) or not options.has_key?(:from)

    placeholder = options[:from]
    minlength = options[:minlength] || 4

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
      page.find("div.select2-result-label", text: %r{#{Regexp.escape(value)}}i).click
    end
  end

  def find_label_by_text(text)
    find(:xpath, "//label[text()[contains(.,'#{text}')]]")
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

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = true
end

RSpec::Matchers.define :have_meta do |name, expected|
  match do |actual|
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

RSpec::Matchers.define :have_title do |expected|
  match do |actual|
    has_css?("title", text: expected, visible: false)
  end

  failure_message do |actual|
    actual = first("title")
    if actual
      "expected that title would have been '#{expected}' but was '#{actual.text}'"
    else
      "expected that title would exist with '#{expected}'"
    end
  end
end

RSpec.configure do |c|
  c.include CapybaraExt
end
