namespace :factories do
  desc "List all factories"
  task list: :environment do
    # TODO: search in all the common factories.rb paths in the various solidus gems
    # Tested with solidus + solidus_stripe
    Gem.loaded_specs.values.each do |spec|
      factory_file = File.join(spec.full_gem_path, "lib/#{spec.name}/testing_support/factories.rb")
      require factory_file if File.file?(factory_file)
    end

    factories = FactoryBot.factories.sort_by { |f| f.build_class.to_s }

    # Find the length of the longest factory name and class name
    longest_name_length = factories.map { |f| f.name.length }.max
    longest_class_length = factories.map { |f| f.build_class.to_s.length }.max

    puts "Factory Name".ljust(longest_name_length) + " | " + "Class Name".ljust(longest_class_length)
    puts "-" * longest_name_length + " | " + "-" * longest_class_length

    factories.each do |factory|
      factory_name = factory.name.to_s.ljust(longest_name_length)
      factory_class = factory.build_class.to_s.ljust(longest_class_length)

      puts "#{factory_name} | #{factory_class}"
    end
  end
end
