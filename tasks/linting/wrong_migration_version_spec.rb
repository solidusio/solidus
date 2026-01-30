# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"

require_relative "wrong_migration_version"

RSpec.describe Solidus::WrongMigrationVersion do
  include RuboCop::RSpec::ExpectOffense

  subject(:cop) { described_class.new RuboCop::Config.new }

  it "finds migration versions greater than the Solidus minimum required Rails version offensive" do
    greater_than_minimum_version = Gem::Version
      .new(Spree.minimum_required_rails_version)
      .bump
      .to_s

    expect_offense(<<~RUBY)
      class TestMigration < ActiveRecord::Migration[#{greater_than_minimum_version}]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Solidus/WrongMigrationVersion: Subclasses of ActiveRecord::Migration must use a migration version of <= 7.2
      end
    RUBY
  end

  it "finds migration versions less than the Solidus minimum required Rails version inoffensive" do
    expect_no_offenses(<<~RUBY)
      class TestMigration < ActiveRecord::Migration[3.0]
      end
    RUBY
  end

  it "finds migration versions equal to the Solidus minimum required Rails version inoffensive" do
    expect_no_offenses(<<~RUBY)
      class TestMigration < ActiveRecord::Migration[#{Spree.minimum_required_rails_version}]
      end
    RUBY
  end

  it "finds non-migration classes inoffensive" do
    expect_no_offenses(<<~RUBY)
      class NotAMigration
      end
    RUBY
  end

  it "finds non-migration subclasses inoffensive" do
    expect_no_offenses(<<~RUBY)
      class SubclassOfNotAMigration < NotAMigration
      end
    RUBY
  end
end
