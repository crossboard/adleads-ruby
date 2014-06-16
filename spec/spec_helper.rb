require 'ad_leads'
require 'rspec'

RSpec.configure do |config|
  config.before :each do
    Logger.stub(:new) { double(:logger, error: nil) }
  end
end
