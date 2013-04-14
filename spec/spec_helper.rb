$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'netica'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'progress'
end

RSpec::Matchers.define :be_less_than do |expected|
  match do |actual|
    actual<expected
  end
end

RSpec::Matchers.define :be_greater_than do |expected|
  match do |actual|
    actual>expected
  end
end