require 'spec_helper'
require 'pry'

describe AdLeads::Client do
  let!(:client) { AdLeads::Client.new }
  let(:connection) { client.connection }
  let(:token) { '55bd8390-9cd9-4b69-9966-1a10a9bc5591' }
  let(:file) { './spec/fixtures/test.jpg' }

  before do
    client.stub(:token).and_return(token)
    AdLeads::Client.stub(:new) { client }
  end

  context 'Network Requests' do
    describe 'Ad Campaign' do
      xit 'uploads logo image, creates campaign using logo image, verifies and launches ad campaign' do

        options = {
          'name' => 'Creative Group Name',
          'productName' =>  'amazing product',
          'privacyPolicyUrl' => 'http://privacy_url'
        }

        client.create_creative_group(options)
        creative_id = client.last_response_id

        options = {
          'type' => 'Mobile',
          'name' =>  'Ad name',
          'headerText' => 'get your ad on this phone today',
          'bodyText' => 'this is mobile ad body copy'
        }

        client.create_ad(creative_id, options)
        ad_id = client.last_response_id

        options = { 'type' => 'LogoImage' }

        client.create_image(creative_id, ad_id, options)
        image_id = client.last_response_id
        client.upload_image(creative_id, ad_id, image_id, file)

        options = {
          'name' => 'Campaign name',
          'verticals' =>  82,
          'offerIncentiveCategory' => 5,
          'collectedFields' => 'firstname,lastname,email,companyname',
          'budget' => 50,
          'creativeGroups' => creative_id
        }

        client.create_campaign(options)
        campaign_id = client.last_response_id

        client.verify_campaign(campaign_id)
        response = client.launch_campaign(campaign_id)

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['result']).to eq true
      end

      xit 'creates complete campaign in one step, verifies and launches ad campaign' do
        options = {
          creative_group: {
            'name' => 'Creative Group Name',
            'productName' =>  'amazing product',
            'privacyPolicyUrl' => 'http://privacy_url'
          },
          ad: {
            'type' => 'Mobile',
            'name' =>  'Ad name',
            'headerText' => 'get your ad on this phone today',
            'bodyText' => 'this is mobile ad body copy'
          },
          image: { 'type' => 'LogoImage' },
          file: file,
          campaign: {
            'name' => 'Campaign name',
            'verticals' =>  82,
            'offerIncentiveCategory' => 5,
            'collectedFields' => 'firstname,lastname,email,companyname',
            'budget' => 50
        }}

        client.create_complete_campaign(options)
        campaign_id = client.last_response_id
        client.verify_campaign(campaign_id)
        client.launch_campaign(campaign_id)

        expect(client.last_response.status).to eq(200)
        expect(JSON.parse(client.last_response.body)['result']).to eq true
      end
    end
  end

end
