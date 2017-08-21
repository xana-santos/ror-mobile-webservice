require 'zeus/parallel_tests'
require 'simplecov'

class CustomPlan < Zeus::ParallelTests::Rails
  def test(argv = ARGV)
    
    ENV['GUARD_RSPEC_RESULTS_FILE'] = 'tmp/guard_rspec_results.txt'
    
    # Start SimpleCov
    SimpleCov.start do

      add_filter 'app/admin/'
      add_filter 'spec/'
      add_filter 'app/helpers/documentation_helper.rb'
      add_filter "app/controllers/concerns/(.*.admin.rb)"
      
      add_group 'Models' do |src_file|
        src_file.filename['app/models'] && !src_file.filename['concern']
      end
      
      add_group 'Controllers' do |src_file|
        src_file.filename['app/controllers'] && !src_file.filename['concern']
      end
      
      add_group "Serializers", "app/serializers"
      add_group "Concerns", ["app/controllers/concerns", "app/models/concerns"]

      add_group "Long files" do |src_file|
        src_file.lines.count > 100
      end
      
      add_group "No-cov filters" do |src_file|
        open(src_file.filename).grep(/:nocov:/).any?
      end

    end

    # Run tests
    super
  end
end

Zeus.plan = CustomPlan.new

ENV['GUARD_NOTIFY'] = 'true'
ENV['GUARD_NOTIFICATIONS'] = "---\n- :name: :terminal_notifier\n  :options: {}\n"