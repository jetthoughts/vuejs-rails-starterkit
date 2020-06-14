# frozen_string_literal: true

if defined?(Spring) && ENV["DISABLE_SPRING"].nil?
  puts "**** NO COVERAGE FOR YOU! ****"
  puts "Please disable Spring to get COVERAGE by `DISABLE_SPRING=1 COVERAGE=1 bin/rspec`"
else
  SimpleCov.start "rails" do
    add_filter %w[app/views bin spec test]

    maximum_coverage_drop 0.5
  end

  if ENV["CODECOV_TOKEN"]
    require "codecov"
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end
