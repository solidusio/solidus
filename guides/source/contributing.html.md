# Contributing

We hope that you will consider contributing to the Solidus documentation.

The Solidus documentation sources are hosted in the main repository
[inside the `guides/` folder](https://github.com/solidusio/solidus/tree/master/guides#readme).

We want to provide the Solidus community with consistent, easy-to-read, and
easy-to-maintain articles. If you decide to submit a pull request, please try to
follow the guidelines listed here.

## Content style

### Accessibility

- Prefer U.S. spelling.
- Prefer short, simple sentences that are under 12 words long.
- Avoid using English-language idioms. [Many idioms are challenging for
  non-native English speakers][idioms]. ("The configuration is simple," not "The
  configuration is a piece of cake.")
- Avoid using jargon English like "e.g." and "i.e." Write out a phrase like "for
  example" instead.
- Avoid words that have multiple meanings (or [homographs][homographs]),
  especially when the meanings may be technical. For example: using the phrase "For
  *instance*" to reference an example might be confused for an *instance* of an
  object.

[homographs]: https://en.wikipedia.org/wiki/List_of_English_homographs
[idioms]: http://www.languages.info/2013/03/05/the-challenges-of-idiom-in-the-english-language/

### Formatting

- Use [GitHub Flavored Markdown][markdown] for article content.
- Break lines when they reach 80 characters unless the characters are a URL or
  Markdown table-formatted lines.
- Prefer [full reference links][full-references-links] to inline Markdown links.
  Full reference links are easier to maintain in the long term.
- Use bold and italic text sparingly.
- Mark text that appears in a GUI using bold text.

[full-reference-links]: https://github.github.com/gfm/#full-reference-link
[markdown]: https://github.github.com/gfm/

### Grammar and capitalization

- Use the Oxford comma in lists. (Peanuts, cashews, and almonds.)
- Use sentence-style capitalization for article titles. ("Asset management", not
  "Asset Management".)
- Use sub-headings to help readers quickly scan and understand the content.
- If a list is longer than three items, break it into bullet points.
- Prefer to write in the present tense. [The present tense is simpler and easier
  to read][present-tense].

[present-tense]: https://www.plainlanguage.gov/guidelines/conversational/use-the-present-tense/

### Code

- Do not abbreviate terminal commands. (`bundle exec rails server`, not `bundle
  exec rails s`.)
- Put filenames, paths, and single-word references to code in `inline` code
  elements. ("Use the `payments` method to get a list of payments.")
- Use [fenced code blocks][fenced-code-blocks] for any amount of example code.
- Describe what the code in each fenced code block does in the text above it.

[fenced-code-blocks]: https://github.github.com/gfm/#fenced-code-blocks

