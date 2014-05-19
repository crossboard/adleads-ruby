require 'spec_helper'
require './spec/fixtures/ad_campaign_obj.rb'
require 'pry'

describe AdLeads::Campaign do
  let(:campaign) { AdLeads::Campaign.new }
  let(:connection) { campaign.connection }
  let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
  let(:token) { 'a2b43ab1-8d09-4ec4-8568-7bb1872cc63b' }

  before do
    campaign.stub(:token).and_return(token)
  end

  ad_campaign_obj = {
  campaign_info: {
    publisher_id: '12345',
    promotion_id: '12345',
    targeting: '{}',
    spend: 250,
    time_start: 011220131212,
    time_start: 011220131412,
    name: 'My campaign'
    },
  content_info: {
    name: 'ad name',
    type: 'Mobile',
    headerText: 'get your ad on this phone today',
    bodyText: 'this is mobile ad body copy',
    privacy: 'http://privacy_url',
    image_type: 'logoImage',
    file: 'test.jpg'
  }
}

  it 'runs campaign_kickoff script' do
    response = campaign.campaign_kickoff(ad_campaign_obj)
    expect(response).to eq(200)
  end
end
