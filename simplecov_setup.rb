# frozen_string_literal: true

return if ENV["COVERAGE"] == "false"

require "simplecov"

unless SimpleCov.running
  SimpleCov.start "rails" do
    command_name ENV.fetch("SIMPLECOV_COMMAND_NAME", "test-suite")
    merge_timeout 3600
    enable_coverage :branch
    add_filter %w[/bin/ /config/ /spec/ /test/ /vendor/]
  end
end
