rspec_options = {
  results_file: 'tmp/guard_rspec_results.txt',
  cmd: "bundle exec time zeus parallel_rspec -o '",
  cmd_additional_args: "'",
  run_all: {
    cmd: "bundle exec time zeus parallel_rspec -o '",
    cmd_additional_args: "'"
  }
}

guard :rspec, rspec_options do
  require "guard/rspec/dsl"
  require 'active_support/inflector'
  require 'zeus/parallel_tests'
  
  dsl = Guard::RSpec::Dsl.new(self)
  notification :terminal_notifier
  
  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  watch(%r{^spec/factories/(.+)\.rb$}) { |m|
    ["spec/models/#{m[1]}_spec.rb", "spec/controllers/#{m[1]}_controller_spec.rb"]
  }
  
  watch(%r{^app/serializers(.+)\.rb$}) { |m|
    ["spec/models#{m[1].gsub('_serializer','')}_spec.rb", "spec/controllers#{m[1].gsub('_serializer','')}_controller_spec.rb"]
  }
  
  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails(view_extensions: %w(erb haml slim))
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  watch(rails.controllers) do |m|
    ["spec/controllers/#{m[1].gsub('v1/','').gsub('_controller','').singularize}_spec.rb"]
  end
  
  watch(%r{^app/controllers/concerns(.+)\.rb$}) { |m|
    ["spec/models#{m[1].gsub('_functions','')}_spec.rb", "spec/controllers#{m[1].gsub('_functions','')}_spec.rb"]
  }

  # Rails config changes
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
  watch(rails.app_controller)  { "#{rspec.spec_dir}/controllers" }

  # Capybara features specs
  watch(rails.view_dirs)     { |m| rspec.spec.("features/#{m[1]}") }
  watch(rails.layouts)       { |m| rspec.spec.("features/#{m[1]}") }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || "spec/acceptance"
  end
    
end
