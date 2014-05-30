require 'spec_helper'
require 'pry'

describe AdLeads::Campaign do
  let(:campaign) { AdLeads::Campaign.new }
  let(:connection) { campaign.connection }
  let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
  let(:token) { '067f6080-913f-4b7b-9034-8240b976094a' }

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
    name: 'My campaign',
    launched: false
    },
  content_info: {
    name: 'ad name',
    type: 'Mobile',
    headerText: 'get your ad on this phone today',
    bodyText: 'this is mobile ad body copy',
    privacy: 'http://privacy_url',
    image_type: 'LogoImage',
    file: 'test.jpg',
    verticals: '82',
    incentives: '5',
    collected_fields: 'firstname,lastname,email'
  }
}

  it 'runs campaign_kickoff script' do
    response = campaign.campaign_kickoff(ad_campaign_obj)
    expect(JSON.parse(response.body)['result']).to eq(true)
  end
end
