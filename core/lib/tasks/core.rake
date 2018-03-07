# frozen_string_literal: true

require 'active_record'

def prompt_for_agree(prompt)
  print prompt
  ["y", "yes"].include? STDIN.gets.strip.downcase
end

namespace :db do
  desc 'Loads a specified fixture file:
use rake db:load_file[/absolute/path/to/sample/filename.rb]'

  task :load_file, [:file, :dir] => :environment do |_t, args|
    Spree::Deprecation.warn("load_file has been deprecated. Please load your own file.")
    file = Pathname.new(args.file)

    puts "loading ruby #{file}"
    require file
  end

  desc "Loads fixtures from the the dir you specify using rake db:load_dir[loadfrom]"
  task :load_dir, [:dir] => :environment do |_t, args|
    Spree::Deprecation.warn("rake spree:load_dir has been deprecated and will be removed with Solidus 3.0. Please load your files directly.")
    dir = args.dir
    dir = File.join(Rails.root, "db", dir) if Pathname.new(dir).relative?

    ruby_files = {}
    Dir.glob(File.join(dir, '**/*.{rb}')).each do |fixture_file|
      ruby_files[File.basename(fixture_file, '.*')] = fixture_file
    end
    ruby_files.sort.each do |fixture, ruby_file|
      # If file is exists within application it takes precendence.
      if File.exist?(File.join(Rails.root, "db/default/spree", "#{fixture}.rb"))
        ruby_file = File.expand_path(File.join(Rails.root, "db/default/spree", "#{fixture}.rb"))
      end
      # an invoke will only execute the task once
      Rake::Task["db:load_file"].execute( Rake::TaskArguments.new([:file], [ruby_file]) )
    end
  end

  desc "Migrate schema to version 0 and back up again. WARNING: Destroys all data in tables!!"
  task remigrate: :environment do
    Spree::Deprecation.warn("remigrate has been deprecated. Please use db:reset or other db: commands instead.")

    if ENV['SKIP_NAG'] || ENV['OVERWRITE'].to_s.casecmp('true') || prompt_for_agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [y/n] ")

      # Drop all tables
      ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.drop_table t }

      # Migrate upward
      Rake::Task["db:migrate"].invoke

      # Dump the schema
      Rake::Task["db:schema:dump"].invoke
    else
      puts "Task cancelled."
      exit
    end
  end

  desc "Bootstrap is: migrating, loading defaults, sample data and seeding (for all extensions) and load_products tasks"
  task :bootstrap do
    Spree::Deprecation.warn("rake bootstrap has been deprecated, please run db:setup instead.")

    # remigrate unless production mode (as saftey check)
    if %w[demo development test].include? Rails.env
      if ENV['AUTO_ACCEPT'] || prompt_for_agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [y/n] ")
        ENV['SKIP_NAG'] = 'yes'
        Rake::Task["db:create"].invoke
        Rake::Task["db:remigrate"].invoke
      else
        puts "Task cancelled, exiting."
        exit
      end
    else
      puts "NOTE: Bootstrap in production mode will not drop database before migration"
      Rake::Task["db:migrate"].invoke
    end

    ActiveRecord::Base.send(:subclasses).each(&:reset_column_information)

    load_defaults = Spree::Country.count == 0
    load_defaults ||= prompt_for_agree('Countries present, load sample data anyways? [y/n]: ')
    if load_defaults
      Rake::Task["db:seed"].invoke
    end

    if Rails.env.production? && Spree::Product.count > 0
      load_sample = prompt_for_agree("WARNING: In Production and products exist in database, load sample data anyways? [y/n]:" )
    else
      load_sample = true if ENV['AUTO_ACCEPT']
      load_sample ||= prompt_for_agree('Load Sample Data? [y/n]: ')
    end

    if load_sample
      # Reload models' attributes in case they were loaded in old migrations with wrong attributes
      ActiveRecord::Base.descendants.each(&:reset_column_information)
      Rake::Task["spree_sample:load"].invoke
    end

    puts "Bootstrap Complete.\n\n"
  end
end
