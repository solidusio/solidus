require 'active_support/core_ext'

module Spree
  module I18nUtils
    # Retrieve comments, translation data in hash form
    def read_file(filename, basename)
      # Add error checking for failed file read?
      (comments, data) = IO.read(filename).split(/#{basename}:\s*\n/)
      return comments, create_hash(data)
    end
    module_function :read_file

    # Creates hash of translation data
    def create_hash(data)
      words = {}
      return words unless data
      parent = []
      previous_key = 'base'
      data.split("\n").each do |w|
        next if w.strip.blank? || w.strip[0] == '#'
        (key, value) = w.split(':', 2)
        value ||= ''
        # Determine level of current key in comparison to parent array
        shift = (key =~ /\w/) / 2 - parent.size
        key = key.sub(/^\s+/, '')
        # If key is child of previous key, add previous key as parent
        parent << previous_key if shift > 0
        # If key is not related to previous key, remove parent keys
        (shift*-1).times { parent.pop } if shift < 0
        # Track key in case next key is child of this key
        previous_key = key
        words[parent.join(':') + ':' + key] = value
      end
      words
    end
    module_function :create_hash

    # Writes to file from translation data hash structure
    def write_file(filename, basename, _comments, words, comment_values = true, _fallback_values = {})
      File.open(filename, 'w') do |log|
        log.puts(basename + ": \n")
        words.sort.each do |k, v|
          keys = k.split(':')
          # Add indentation for children keys
          (keys.size - 1).times do
            keys[keys.size - 1] = '  ' + keys[keys.size - 1]
          end
          value = v.strip
          value = ('#' + value) if comment_values && !value.blank?
          log.puts "#{keys[keys.size - 1]}: #{value}\n"
        end
      end
    end
    module_function :write_file
  end
end
