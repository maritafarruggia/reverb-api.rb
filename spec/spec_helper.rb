$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'reverb/api'
require 'webmock/rspec'
require 'vcr'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
end

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
