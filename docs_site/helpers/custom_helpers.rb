# frozen_string_literal: true

module CustomHelpers
  def full_title(site_title, page_title = nil)
    page_title ||= ""
    if page_title.empty?
      site_title
    else
      page_title + " | " + site_title
    end
  end

  def smart_robots(path, env)
    # Add paths (like "thank you" pages) that search engines should not index.
    # Multiple paths look like this:
    # /first_path|another_path|yet_another/
    if !!(path =~ /thanks/) || env != "production"
      "noindex, nofollow"
    else
      "index, follow"
    end
  end

  # return "active" if current page = path. used for navigation classes
  def nav_active(path)
    (current_page.path.start_with? path) ? "active" : ""
  end

  # return "active" if current page is not in paths array. used for navigation classes
  def nav_inactive(paths)
    cls = "no-active"
    paths.each do |path|
      if current_page.path.start_with?(path)
        cls = ""
      end
    end
    cls
  end
end
